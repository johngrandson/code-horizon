defmodule CodeHorizonWeb.UserNotificationsChannelTest do
  use CodeHorizonWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      CodeHorizonWeb.UserSocket
      |> socket("user_id", %{user_id: "user_id"})
      |> subscribe_and_join(CodeHorizonWeb.UserNotificationsChannel, "user_notifications:user_id")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "user_notifications:user_id", "notifications_updated")
    assert_push "user_notifications:user_id", "notifications_updated"
  end
end
