defmodule CodeHorizon.Enrollments.EnrollmentStatus do
  @moduledoc false
  @statuses [:active, :completed, :paused, :cancelled, :expired]

  def all, do: @statuses

  def valid?(status) when status in @statuses, do: true
  def valid?(_), do: false

  def can_transition?(from, to)
  def can_transition?(:active, :completed), do: true
  def can_transition?(:active, :cancelled), do: true
  def can_transition?(:active, :paused), do: true
  def can_transition?(:paused, :active), do: true
  def can_transition?(:paused, :cancelled), do: true
  def can_transition?(_, _), do: false
end
