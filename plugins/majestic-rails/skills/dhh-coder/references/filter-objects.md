# Filter Objects

Extract filtering logic into POROs for testable, reusable query building.

## Basic Filter Object

```ruby
class CardFilter
  PERMITTED_PARAMS = %i[search assignee_id label_id status priority].freeze

  attr_reader :params, :scope

  def initialize(scope, params = {})
    @scope = scope
    @params = params.slice(*PERMITTED_PARAMS)
  end

  def results
    @results ||= apply_filters
  end

  private
    def apply_filters
      filtered = scope
      filtered = filter_by_search(filtered)
      filtered = filter_by_assignee(filtered)
      filtered = filter_by_label(filtered)
      filtered = filter_by_status(filtered)
      filtered = filter_by_priority(filtered)
      filtered.distinct
    end

    def filter_by_search(scope)
      return scope if params[:search].blank?
      scope.where("title ILIKE ?", "%#{params[:search]}%")
    end

    def filter_by_assignee(scope)
      return scope if params[:assignee_id].blank?
      scope.where(assignee_id: params[:assignee_id])
    end

    def filter_by_label(scope)
      return scope if params[:label_id].blank?
      scope.joins(:labels).where(labels: { id: params[:label_id] })
    end

    def filter_by_status(scope)
      return scope if params[:status].blank?
      scope.where(status: params[:status])
    end

    def filter_by_priority(scope)
      return scope if params[:priority].blank?
      scope.where(priority: params[:priority])
    end
end
```

## URL Parameter Conversion

```ruby
class CardFilter
  DEFAULT_VALUES = { status: "open" }.freeze

  def as_params
    params.compact_blank.reject { |k, v| default_value?(k, v) }
  end

  def as_params_without(*keys)
    as_params.except(*keys)
  end

  private
    def default_value?(key, value)
      DEFAULT_VALUES[key.to_sym] == value
    end
end
```

## Controller Integration

```ruby
module FilterScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_filter
    helper_method :filter
  end

  private
    def filter
      @filter
    end

    def set_filter
      @filter = filter_class.new(base_scope, filter_params)
    end

    def filter_params
      params.permit(*filter_class::PERMITTED_PARAMS)
    end

    # Override in controller
    def filter_class
      raise NotImplementedError
    end

    def base_scope
      raise NotImplementedError
    end
end

class CardsController < ApplicationController
  include FilterScoped

  def index
    @cards = filter.results.page(params[:page])
  end

  private
    def filter_class = CardFilter
    def base_scope = Current.account.cards
end
```

## Filter Chips as Links

```erb
<%# app/views/cards/_active_filters.html.erb %>
<div class="flex gap-2">
  <% if filter.params[:assignee_id].present? %>
    <%= link_to cards_path(filter.as_params_without(:assignee_id)),
        class: "chip chip--removable" do %>
      <%= User.find(filter.params[:assignee_id]).name %>
      <span class="chip__remove">&times;</span>
    <% end %>
  <% end %>

  <% if filter.params[:label_id].present? %>
    <%= link_to cards_path(filter.as_params_without(:label_id)),
        class: "chip chip--removable" do %>
      <%= Label.find(filter.params[:label_id]).name %>
      <span class="chip__remove">&times;</span>
    <% end %>
  <% end %>
</div>
```

## Debounced Search Stimulus

```javascript
// app/javascript/controllers/filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item"]
  static values = { delay: { type: Number, default: 150 } }

  filter() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.applyFilter(), this.delayValue)
  }

  applyFilter() {
    const query = this.inputTarget.value.toLowerCase()

    this.itemTargets.forEach(item => {
      const text = item.textContent.toLowerCase()
      item.hidden = !text.includes(query)
    })

    this.dispatch("changed", { detail: { query } })
  }
}
```

## Unit Testing Filters

```ruby
class CardFilterTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:acme)
    @scope = @account.cards
  end

  test "filters by search term" do
    filter = CardFilter.new(@scope, search: "urgent")
    assert_includes filter.results, cards(:urgent_bug)
    refute_includes filter.results, cards(:normal_task)
  end

  test "filters by multiple criteria" do
    filter = CardFilter.new(@scope,
      assignee_id: users(:alice).id,
      status: "open"
    )

    assert filter.results.all? { |c| c.assignee_id == users(:alice).id }
    assert filter.results.all? { |c| c.status == "open" }
  end

  test "as_params excludes default values" do
    filter = CardFilter.new(@scope, status: "open", priority: "high")
    assert_equal({ priority: "high" }, filter.as_params)
  end

  test "as_params_without removes specified keys" do
    filter = CardFilter.new(@scope, assignee_id: 1, label_id: 2)
    assert_equal({ label_id: 2 }, filter.as_params_without(:assignee_id))
  end
end
```
