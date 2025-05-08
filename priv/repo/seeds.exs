# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CodeHorizon.Repo.insert!(%CodeHorizon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias CodeHorizon.Accounts.User
alias CodeHorizon.Accounts.UserSeeder
alias CodeHorizon.Accounts.UserToken
alias CodeHorizon.Accounts.UserTOTP
alias CodeHorizon.Files.File
alias CodeHorizon.Files.FileSeeder
alias CodeHorizon.Logs.Log
alias CodeHorizon.Orgs.Invitation
alias CodeHorizon.Orgs.Membership
alias CodeHorizon.Orgs.Org
alias CodeHorizon.Orgs.OrgSeeder
alias CodeHorizon.Posts.Post
alias CodeHorizon.Posts.PostSeeder

if Mix.env() == :dev do
  CodeHorizon.Repo.delete_all(Log)
  CodeHorizon.Repo.delete_all(UserTOTP)
  CodeHorizon.Repo.delete_all(Invitation)
  CodeHorizon.Repo.delete_all(Membership)
  CodeHorizon.Repo.delete_all(Org)
  CodeHorizon.Repo.delete_all(UserToken)
  CodeHorizon.Repo.delete_all(User)
  CodeHorizon.Repo.delete_all(Post)
  CodeHorizon.Repo.delete_all(File)

  admin = UserSeeder.admin()

  normal_user =
    UserSeeder.normal_user(%{
      email: "user@example.com",
      name: "Sarah Cunningham",
      password: "password",
      confirmed_at: Timex.to_naive_datetime(DateTime.utc_now())
    })

  UserSeeder.fake_subscription(normal_user)

  org = OrgSeeder.random_org(admin)
  CodeHorizon.Orgs.create_invitation(org, %{email: normal_user.email})

  UserSeeder.random_users(20)

  FileSeeder.create_files(admin)
  PostSeeder.create_posts(admin)
end
