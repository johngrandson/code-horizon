defmodule CodeHorizon.AssessmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.Assessments` context.
  """

  @doc """
  Generate a assessment.
  """
  def assessment_fixture(attrs \\ %{}) do
    {:ok, assessment} =
      attrs
      |> Enum.into(%{
        assessment_type: :quiz,
        description: "some description",
        is_published: true,
        max_attempts: 42,
        passing_score: 42,
        time_limit_minutes: 42,
        title: "some title"
      })
      |> CodeHorizon.Assessments.create_assessment()

    assessment
  end

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        order: 42,
        points: 42,
        question_text: "some question_text",
        question_type: :multiple_choice
      })
      |> CodeHorizon.Assessments.create_question()

    question
  end

  @doc """
  Generate a question_option.
  """
  def question_option_fixture(attrs \\ %{}) do
    {:ok, question_option} =
      attrs
      |> Enum.into(%{
        is_correct: true,
        option_text: "some option_text",
        order: 42
      })
      |> CodeHorizon.Assessments.create_question_option()

    question_option
  end

  @doc """
  Generate a assessment_attempt.
  """
  def assessment_attempt_fixture(attrs \\ %{}) do
    {:ok, assessment_attempt} =
      attrs
      |> Enum.into(%{
        end_time: ~U[2025-05-07 20:56:00Z],
        score: 42,
        start_time: ~U[2025-05-07 20:56:00Z],
        status: :in_progress
      })
      |> CodeHorizon.Assessments.create_assessment_attempt()

    assessment_attempt
  end

  @doc """
  Generate a attempt_answer.
  """
  def attempt_answer_fixture(attrs \\ %{}) do
    {:ok, attempt_answer} =
      attrs
      |> Enum.into(%{
        answer_text: "some answer_text",
        is_correct: true,
        points_awarded: 42
      })
      |> CodeHorizon.Assessments.create_attempt_answer()

    attempt_answer
  end
end
