defmodule CodeHorizon.StudentDashboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CodeHorizon.StudentDashboard` context.
  """

  alias CodeHorizon.Activities.Activity
  alias CodeHorizon.Assessments.Assessment
  alias CodeHorizon.Courses.Course
  alias CodeHorizon.LearningStats

  @doc """
  Generate a student dashboard fixture.

  ## Examples

      iex> dashboard_fixture(student_id)
      %StudentDashboard{...}
  """
  def dashboard_fixture(student_id, attrs \\ %{}) do
    # Define default data
    enrolled_courses = attrs[:enrolled_courses] || generate_enrolled_courses()
    upcoming_assessments = attrs[:upcoming_assessments] || generate_upcoming_assessments()
    recent_activity = attrs[:recent_activity] || generate_recent_activity(student_id)
    recommended_courses = attrs[:recommended_courses] || generate_recommended_courses()
    learning_stats = attrs[:learning_stats] || generate_learning_stats(enrolled_courses)

    # Get the dashboard using actual function or build it manually
    # Option 1: Use the actual function if data is properly seeded in test DB
    # CodeHorizon.StudentDashboard.get_student_dashboard!(student_id)

    # Option 2: Build the dashboard struct manually (preferred for isolated tests)
    %CodeHorizon.StudentDashboard{
      id: student_id,
      enrolled_courses: enrolled_courses,
      upcoming_assessments: upcoming_assessments,
      recent_activity: recent_activity,
      recommended_courses: recommended_courses,
      learning_stats: learning_stats
    }
  end

  @doc """
  Generate mock enrolled courses for testing.
  """
  def generate_enrolled_courses do
    [
      %Course{
        id: "course-1",
        title: "Introduction to Programming",
        cover_image: "/images/courses/programming.jpg",
        description: "Learn the basics of programming with this beginner-friendly course",
        instructor: %{name: "John Doe", avatar: "/images/avatars/john.jpg"},
        progress: 75,
        duration: "6 weeks",
        level: "Beginner",
        last_updated: "2 weeks ago",
        category: "Programming"
      },
      %Course{
        id: "course-2",
        title: "Web Development Fundamentals",
        cover_image: "/images/courses/web-dev.jpg",
        description: "Master HTML, CSS and JavaScript basics",
        instructor: %{name: "Jane Smith", avatar: "/images/avatars/jane.jpg"},
        progress: 45,
        duration: "8 weeks",
        level: "Intermediate",
        last_updated: "1 week ago",
        category: "Web Development"
      },
      %Course{
        id: "course-3",
        title: "Data Structures and Algorithms",
        cover_image: "/images/courses/algorithms.jpg",
        description: "Learn essential algorithms and data structures",
        instructor: %{name: "Alan Turing", avatar: "/images/avatars/alan.jpg"},
        progress: 30,
        duration: "10 weeks",
        level: "Advanced",
        last_updated: "3 days ago",
        category: "Computer Science"
      }
    ]
  end

  @doc """
  Generate mock upcoming assessments for testing.
  """
  def generate_upcoming_assessments do
    [
      %Assessment{
        id: "assessment-1",
        title: "Programming Basics Quiz",
        course_title: "Introduction to Programming",
        assessment_type: :quiz,
        due_date: Date.add(Date.utc_today(), 3),
        time_limit_minutes: 30,
        total_points: 100
      },
      %Assessment{
        id: "assessment-2",
        title: "HTML & CSS Project",
        course_title: "Web Development Fundamentals",
        assessment_type: :assignment,
        due_date: Date.add(Date.utc_today(), 7),
        total_points: 100
      },
      %Assessment{
        id: "assessment-3",
        title: "Algorithms Midterm Exam",
        course_title: "Data Structures and Algorithms",
        assessment_type: :exam,
        # Overdue assessment
        due_date: Date.add(Date.utc_today(), -1),
        time_limit_minutes: 120,
        total_points: 100
      }
    ]
  end

  @doc """
  Generate mock recent activity for testing.
  """
  def generate_recent_activity(student_id) do
    [
      %Activity{
        id: "activity-1",
        type: :course_enrolled,
        course_id: "course-1",
        course_title: "Introduction to Programming",
        timestamp: DateTime.add(DateTime.utc_now(), -1 * 60 * 60, :second),
        user_id: student_id
      },
      %Activity{
        id: "activity-2",
        type: :lesson_completed,
        course_id: "course-2",
        course_title: "Web Development Fundamentals",
        lesson_title: "CSS Flexbox Layout",
        timestamp: DateTime.add(DateTime.utc_now(), -5 * 60 * 60, :second),
        user_id: student_id
      },
      %Activity{
        id: "activity-3",
        type: :assessment_completed,
        assessment_id: "assessment-1",
        assessment_title: "JavaScript Basics Quiz",
        course_title: "Web Development Fundamentals",
        score: 85,
        timestamp: DateTime.add(DateTime.utc_now(), -2 * 86_400, :second),
        user_id: student_id
      }
    ]
  end

  @doc """
  Generate mock recommended courses for testing.
  """
  def generate_recommended_courses do
    [
      %Course{
        id: "rec-course-1",
        title: "Database Design",
        cover_image: "/images/courses/database.jpg",
        description: "Learn how to design efficient databases",
        instructor: %{name: "Maria Garcia", avatar: "/images/avatars/maria.jpg"},
        duration: "8 weeks",
        level: "Intermediate",
        last_updated: "1 month ago",
        category: "Databases",
        rating: 4.7,
        review_count: 152,
        price: 49.99
      },
      %Course{
        id: "rec-course-2",
        title: "Machine Learning Fundamentals",
        cover_image: "/images/courses/ml.jpg",
        description: "Introduction to machine learning concepts and algorithms",
        instructor: %{name: "David Lee", avatar: "/images/avatars/david.jpg"},
        duration: "12 weeks",
        level: "Advanced",
        last_updated: "2 weeks ago",
        category: "Artificial Intelligence",
        is_premium: true,
        rating: 4.9,
        review_count: 243,
        price: 69.99,
        original_price: 99.99,
        discount_percentage: 30
      },
      %Course{
        id: "rec-course-3",
        title: "Mobile App Development",
        cover_image: "/images/courses/mobile.jpg",
        description: "Learn to build cross-platform mobile applications",
        instructor: %{name: "Sarah Johnson", avatar: "/images/avatars/sarah.jpg"},
        duration: "10 weeks",
        level: "Intermediate",
        last_updated: "3 days ago",
        category: "Mobile Development",
        rating: 4.5,
        review_count: 189,
        price: 59.99
      },
      %Course{
        id: "rec-course-4",
        title: "Python for Data Science",
        cover_image: "/images/courses/python-data.jpg",
        description: "Master data analysis with Python",
        instructor: %{name: "Michael Brown", avatar: "/images/avatars/michael.jpg"},
        duration: "8 weeks",
        level: "Intermediate",
        last_updated: "1 week ago",
        category: "Data Science",
        rating: 4.8,
        review_count: 312,
        is_free: true
      }
    ]
  end

  @doc """
  Generate mock learning stats for testing.
  Optionally calculates based on provided courses.
  """
  def generate_learning_stats(courses \\ []) do
    completed_courses = if Enum.empty?(courses), do: 3, else: Enum.count(courses, &(&1.progress == 100))

    courses_in_progress =
      if Enum.empty?(courses), do: 5, else: Enum.count(courses, &(&1.progress > 0 && &1.progress < 100))

    total_courses = if Enum.empty?(courses), do: 12, else: Enum.count(courses)
    avg_progress = if Enum.empty?(courses), do: 48, else: calculate_avg_progress(courses)

    %LearningStats{
      completed_courses: completed_courses,
      courses_in_progress: courses_in_progress,
      total_courses: total_courses,
      avg_progress: avg_progress
    }
  end

  # Helper function to calculate average progress
  defp calculate_avg_progress(courses) do
    total_progress = Enum.reduce(courses, 0, fn course, acc -> acc + (course.progress || 0) end)
    course_count = length(courses)

    if course_count > 0, do: div(total_progress, course_count), else: 0
  end
end
