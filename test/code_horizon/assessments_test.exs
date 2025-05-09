defmodule CodeHorizon.AssessmentsTest do
  use CodeHorizon.DataCase

  alias CodeHorizon.Assessments

  describe "assessments" do
    alias CodeHorizon.Assessments.Assessment

    import CodeHorizon.AssessmentsFixtures

    @invalid_attrs %{max_attempts: nil, description: nil, title: nil, passing_score: nil, time_limit_minutes: nil, assessment_type: nil, is_published: nil}

    test "list_assessments/0 returns all assessments" do
      assessment = assessment_fixture()
      assert Assessments.list_assessments() == [assessment]
    end

    test "get_assessment!/1 returns the assessment with given id" do
      assessment = assessment_fixture()
      assert Assessments.get_assessment!(assessment.id) == assessment
    end

    test "create_assessment/1 with valid data creates a assessment" do
      valid_attrs = %{max_attempts: 42, description: "some description", title: "some title", passing_score: 42, time_limit_minutes: 42, assessment_type: :quiz, is_published: true}

      assert {:ok, %Assessment{} = assessment} = Assessments.create_assessment(valid_attrs)
      assert assessment.max_attempts == 42
      assert assessment.description == "some description"
      assert assessment.title == "some title"
      assert assessment.passing_score == 42
      assert assessment.time_limit_minutes == 42
      assert assessment.assessment_type == :quiz
      assert assessment.is_published == true
    end

    test "create_assessment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assessments.create_assessment(@invalid_attrs)
    end

    test "update_assessment/2 with valid data updates the assessment" do
      assessment = assessment_fixture()
      update_attrs = %{max_attempts: 43, description: "some updated description", title: "some updated title", passing_score: 43, time_limit_minutes: 43, assessment_type: :assignment, is_published: false}

      assert {:ok, %Assessment{} = assessment} = Assessments.update_assessment(assessment, update_attrs)
      assert assessment.max_attempts == 43
      assert assessment.description == "some updated description"
      assert assessment.title == "some updated title"
      assert assessment.passing_score == 43
      assert assessment.time_limit_minutes == 43
      assert assessment.assessment_type == :assignment
      assert assessment.is_published == false
    end

    test "update_assessment/2 with invalid data returns error changeset" do
      assessment = assessment_fixture()
      assert {:error, %Ecto.Changeset{}} = Assessments.update_assessment(assessment, @invalid_attrs)
      assert assessment == Assessments.get_assessment!(assessment.id)
    end

    test "delete_assessment/1 deletes the assessment" do
      assessment = assessment_fixture()
      assert {:ok, %Assessment{}} = Assessments.delete_assessment(assessment)
      assert_raise Ecto.NoResultsError, fn -> Assessments.get_assessment!(assessment.id) end
    end

    test "change_assessment/1 returns a assessment changeset" do
      assessment = assessment_fixture()
      assert %Ecto.Changeset{} = Assessments.change_assessment(assessment)
    end
  end

  describe "questions" do
    alias CodeHorizon.Assessments.Question

    import CodeHorizon.AssessmentsFixtures

    @invalid_attrs %{order: nil, question_text: nil, question_type: nil, points: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Assessments.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Assessments.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{order: 42, question_text: "some question_text", question_type: :multiple_choice, points: 42}

      assert {:ok, %Question{} = question} = Assessments.create_question(valid_attrs)
      assert question.order == 42
      assert question.question_text == "some question_text"
      assert question.question_type == :multiple_choice
      assert question.points == 42
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assessments.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{order: 43, question_text: "some updated question_text", question_type: :single_choice, points: 43}

      assert {:ok, %Question{} = question} = Assessments.update_question(question, update_attrs)
      assert question.order == 43
      assert question.question_text == "some updated question_text"
      assert question.question_type == :single_choice
      assert question.points == 43
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Assessments.update_question(question, @invalid_attrs)
      assert question == Assessments.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Assessments.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Assessments.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Assessments.change_question(question)
    end
  end

  describe "question_options" do
    alias CodeHorizon.Assessments.QuestionOption

    import CodeHorizon.AssessmentsFixtures

    @invalid_attrs %{order: nil, option_text: nil, is_correct: nil}

    test "list_question_options/0 returns all question_options" do
      question_option = question_option_fixture()
      assert Assessments.list_question_options() == [question_option]
    end

    test "get_question_option!/1 returns the question_option with given id" do
      question_option = question_option_fixture()
      assert Assessments.get_question_option!(question_option.id) == question_option
    end

    test "create_question_option/1 with valid data creates a question_option" do
      valid_attrs = %{order: 42, option_text: "some option_text", is_correct: true}

      assert {:ok, %QuestionOption{} = question_option} = Assessments.create_question_option(valid_attrs)
      assert question_option.order == 42
      assert question_option.option_text == "some option_text"
      assert question_option.is_correct == true
    end

    test "create_question_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assessments.create_question_option(@invalid_attrs)
    end

    test "update_question_option/2 with valid data updates the question_option" do
      question_option = question_option_fixture()
      update_attrs = %{order: 43, option_text: "some updated option_text", is_correct: false}

      assert {:ok, %QuestionOption{} = question_option} = Assessments.update_question_option(question_option, update_attrs)
      assert question_option.order == 43
      assert question_option.option_text == "some updated option_text"
      assert question_option.is_correct == false
    end

    test "update_question_option/2 with invalid data returns error changeset" do
      question_option = question_option_fixture()
      assert {:error, %Ecto.Changeset{}} = Assessments.update_question_option(question_option, @invalid_attrs)
      assert question_option == Assessments.get_question_option!(question_option.id)
    end

    test "delete_question_option/1 deletes the question_option" do
      question_option = question_option_fixture()
      assert {:ok, %QuestionOption{}} = Assessments.delete_question_option(question_option)
      assert_raise Ecto.NoResultsError, fn -> Assessments.get_question_option!(question_option.id) end
    end

    test "change_question_option/1 returns a question_option changeset" do
      question_option = question_option_fixture()
      assert %Ecto.Changeset{} = Assessments.change_question_option(question_option)
    end
  end

  describe "assessment_attempts" do
    alias CodeHorizon.Assessments.AssessmentAttempt

    import CodeHorizon.AssessmentsFixtures

    @invalid_attrs %{status: nil, score: nil, start_time: nil, end_time: nil}

    test "list_assessment_attempts/0 returns all assessment_attempts" do
      assessment_attempt = assessment_attempt_fixture()
      assert Assessments.list_assessment_attempts() == [assessment_attempt]
    end

    test "get_assessment_attempt!/1 returns the assessment_attempt with given id" do
      assessment_attempt = assessment_attempt_fixture()
      assert Assessments.get_assessment_attempt!(assessment_attempt.id) == assessment_attempt
    end

    test "create_assessment_attempt/1 with valid data creates a assessment_attempt" do
      valid_attrs = %{status: :in_progress, score: 42, start_time: ~U[2025-05-07 20:56:00Z], end_time: ~U[2025-05-07 20:56:00Z]}

      assert {:ok, %AssessmentAttempt{} = assessment_attempt} = Assessments.create_assessment_attempt(valid_attrs)
      assert assessment_attempt.status == :in_progress
      assert assessment_attempt.score == 42
      assert assessment_attempt.start_time == ~U[2025-05-07 20:56:00Z]
      assert assessment_attempt.end_time == ~U[2025-05-07 20:56:00Z]
    end

    test "create_assessment_attempt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assessments.create_assessment_attempt(@invalid_attrs)
    end

    test "update_assessment_attempt/2 with valid data updates the assessment_attempt" do
      assessment_attempt = assessment_attempt_fixture()
      update_attrs = %{status: :submitted, score: 43, start_time: ~U[2025-05-08 20:56:00Z], end_time: ~U[2025-05-08 20:56:00Z]}

      assert {:ok, %AssessmentAttempt{} = assessment_attempt} = Assessments.update_assessment_attempt(assessment_attempt, update_attrs)
      assert assessment_attempt.status == :submitted
      assert assessment_attempt.score == 43
      assert assessment_attempt.start_time == ~U[2025-05-08 20:56:00Z]
      assert assessment_attempt.end_time == ~U[2025-05-08 20:56:00Z]
    end

    test "update_assessment_attempt/2 with invalid data returns error changeset" do
      assessment_attempt = assessment_attempt_fixture()
      assert {:error, %Ecto.Changeset{}} = Assessments.update_assessment_attempt(assessment_attempt, @invalid_attrs)
      assert assessment_attempt == Assessments.get_assessment_attempt!(assessment_attempt.id)
    end

    test "delete_assessment_attempt/1 deletes the assessment_attempt" do
      assessment_attempt = assessment_attempt_fixture()
      assert {:ok, %AssessmentAttempt{}} = Assessments.delete_assessment_attempt(assessment_attempt)
      assert_raise Ecto.NoResultsError, fn -> Assessments.get_assessment_attempt!(assessment_attempt.id) end
    end

    test "change_assessment_attempt/1 returns a assessment_attempt changeset" do
      assessment_attempt = assessment_attempt_fixture()
      assert %Ecto.Changeset{} = Assessments.change_assessment_attempt(assessment_attempt)
    end
  end

  describe "attempt_answers" do
    alias CodeHorizon.Assessments.AttemptAnswer

    import CodeHorizon.AssessmentsFixtures

    @invalid_attrs %{is_correct: nil, answer_text: nil, points_awarded: nil}

    test "list_attempt_answers/0 returns all attempt_answers" do
      attempt_answer = attempt_answer_fixture()
      assert Assessments.list_attempt_answers() == [attempt_answer]
    end

    test "get_attempt_answer!/1 returns the attempt_answer with given id" do
      attempt_answer = attempt_answer_fixture()
      assert Assessments.get_attempt_answer!(attempt_answer.id) == attempt_answer
    end

    test "create_attempt_answer/1 with valid data creates a attempt_answer" do
      valid_attrs = %{is_correct: true, answer_text: "some answer_text", points_awarded: 42}

      assert {:ok, %AttemptAnswer{} = attempt_answer} = Assessments.create_attempt_answer(valid_attrs)
      assert attempt_answer.is_correct == true
      assert attempt_answer.answer_text == "some answer_text"
      assert attempt_answer.points_awarded == 42
    end

    test "create_attempt_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assessments.create_attempt_answer(@invalid_attrs)
    end

    test "update_attempt_answer/2 with valid data updates the attempt_answer" do
      attempt_answer = attempt_answer_fixture()
      update_attrs = %{is_correct: false, answer_text: "some updated answer_text", points_awarded: 43}

      assert {:ok, %AttemptAnswer{} = attempt_answer} = Assessments.update_attempt_answer(attempt_answer, update_attrs)
      assert attempt_answer.is_correct == false
      assert attempt_answer.answer_text == "some updated answer_text"
      assert attempt_answer.points_awarded == 43
    end

    test "update_attempt_answer/2 with invalid data returns error changeset" do
      attempt_answer = attempt_answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Assessments.update_attempt_answer(attempt_answer, @invalid_attrs)
      assert attempt_answer == Assessments.get_attempt_answer!(attempt_answer.id)
    end

    test "delete_attempt_answer/1 deletes the attempt_answer" do
      attempt_answer = attempt_answer_fixture()
      assert {:ok, %AttemptAnswer{}} = Assessments.delete_attempt_answer(attempt_answer)
      assert_raise Ecto.NoResultsError, fn -> Assessments.get_attempt_answer!(attempt_answer.id) end
    end

    test "change_attempt_answer/1 returns a attempt_answer changeset" do
      attempt_answer = attempt_answer_fixture()
      assert %Ecto.Changeset{} = Assessments.change_attempt_answer(attempt_answer)
    end
  end
end
