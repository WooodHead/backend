defmodule ReWeb.GraphQL.UsersTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers
  alias Re.User
  alias Comeonin.Bcrypt

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    admin_user = insert(:user, email: "admin@email.com", role: "admin")
    user_user = insert(:user, email: "user@email.com", role: "user")

    {:ok,
     unauthenticated_conn: conn,
     admin_user: admin_user,
     user_user: user_user,
     admin_conn: login_as(conn, admin_user),
     user_conn: login_as(conn, user_user)}
  end

  describe "activateListing" do
    test "admin should get favorited listings", %{admin_conn: conn, admin_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      query = """
        {
          favoritedListings {
            id
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "favoritedListings"))

      listing_id = to_string(listing.id)
      assert %{"favoritedListings" => [%{"id" => ^listing_id}]} = json_response(conn, 200)["data"]
    end

    test "user should get favorited listings", %{user_conn: conn, user_user: user} do
      listing = insert(:listing)
      insert(:listings_favorites, listing_id: listing.id, user_id: user.id)

      query = """
        {
          favoritedListings {
            id
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "favoritedListings"))

      listing_id = to_string(listing.id)
      assert %{"favoritedListings" => [%{"id" => ^listing_id}]} = json_response(conn, 200)["data"]
    end

    test "anonymous should not get favorited listing", %{unauthenticated_conn: conn} do
      query = """
        {
          favoritedListings {
            id
          }
        }
      """

      conn =
        post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "favoritedListings"))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "userProfile" do
    test "admin should get any user profile", %{admin_conn: conn} do
      inserted_user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      listing1 = insert(:listing, user: inserted_user, type: "Casa", score: 4)
      insert(:listing, user: inserted_user, type: "Casa", score: 3)
      insert(:listing, user: inserted_user, type: "Apartamento")

      favorited_listing1 = insert(:listing, type: "Casa", score: 4)
      favorited_listing2 = insert(:listing, type: "Casa", score: 3)
      favorited_listing3 = insert(:listing, type: "Apartamento")

      insert(:listings_favorites, listing: favorited_listing1, user: inserted_user)
      insert(:listings_favorites, listing: favorited_listing2, user: inserted_user)
      insert(:listings_favorites, listing: favorited_listing3, user: inserted_user)

      query = """
        {
          userProfile(ID: #{inserted_user.id}) {
            id
            name
            email
            phone
            listings (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
            favorites (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      user_id = to_string(inserted_user.id)
      user_name = to_string(inserted_user.name)
      user_email = to_string(inserted_user.email)
      user_phone = to_string(inserted_user.phone)
      listing1_id = to_string(listing1.id)
      favorited_listing1_id = to_string(favorited_listing1.id)

      assert %{
               "userProfile" => %{
                 "id" => ^user_id,
                 "name" => ^user_name,
                 "email" => ^user_email,
                 "phone" => ^user_phone,
                 "listings" => [
                   %{"id" => ^listing1_id}
                 ],
                 "favorites" => [
                   %{"id" => ^favorited_listing1_id}
                 ]
               }
             } = json_response(conn, 200)["data"]
    end

    test "user should get his own profile", %{user_conn: conn, user_user: user} do
      listing1 = insert(:listing, user: user, type: "Casa", score: 4)
      insert(:listing, user: user, type: "Casa", score: 3)
      insert(:listing, user: user, type: "Apartamento")

      favorited_listing1 = insert(:listing, type: "Casa", score: 4)
      favorited_listing2 = insert(:listing, type: "Casa", score: 3)
      favorited_listing3 = insert(:listing, type: "Apartamento")

      insert(:listings_favorites, listing: favorited_listing1, user: user)
      insert(:listings_favorites, listing: favorited_listing2, user: user)
      insert(:listings_favorites, listing: favorited_listing3, user: user)

      query = """
        {
          userProfile(ID: #{user.id}) {
            id
            name
            email
            phone
            listings (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
            favorites (
              pagination: {pageSize: 1}
              filters: {types: ["Casa"]}
            ) {
              id
            }
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      user_id = to_string(user.id)
      user_name = to_string(user.name)
      user_email = to_string(user.email)
      user_phone = to_string(user.phone)
      listing1_id = to_string(listing1.id)
      favorited_listing1_id = to_string(favorited_listing1.id)

      assert %{
               "userProfile" => %{
                 "id" => ^user_id,
                 "name" => ^user_name,
                 "email" => ^user_email,
                 "phone" => ^user_phone,
                 "listings" => [
                   %{"id" => ^listing1_id}
                 ],
                 "favorites" => [
                   %{"id" => ^favorited_listing1_id}
                 ]
               }
             } = json_response(conn, 200)["data"]
    end

    test "anonymous should not get user profile", %{unauthenticated_conn: conn} do
      user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      query = """
        {
          userProfile(ID: #{user.id}) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "user should not get other user's profile", %{user_conn: conn} do
      inserted_user =
        insert(:user, name: "Tester John", email: "tester.john@emcasa.com", phone: "123456789")

      query = """
        {
          userProfile(ID: #{inserted_user.id}) {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "userProfile"))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end
  end

  describe "editUserProfile" do
    test "admin should edit any profile", %{admin_conn: conn} do
      user = insert(:user)

      mutation = """
        mutation {
          editUserProfile(
            id: #{user.id},
            name: "Fixed Name",
            phone: "123321123",
            notificationPreferences: {email: false, app: false})
          {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert user = Repo.get(User, user.id)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
    end

    test "user should edit own profile", %{user_conn: conn, user_user: user} do
      mutation = """
        mutation {
          editUserProfile(
            id: #{user.id},
            name: "Fixed Name",
            phone: "123321123",
            notificationPreferences: {email: false, app: false})
          {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert user = Repo.get(User, user.id)
      assert user.name == "Fixed Name"
      assert user.phone == "123321123"
      refute user.notification_preferences.email
      refute user.notification_preferences.app
    end

    test "user should not edit other user's  profile", %{user_conn: conn} do
      inserted_user = insert(:user)

      mutation = """
        mutation {
          editUserProfile(id: #{inserted_user.id}, name: "A Name") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      mutation = """
        mutation {
          editUserProfile(id: #{user.id}, name: "A Name") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end

  describe "changeEmail" do
    test "admin should change email", %{admin_conn: conn} do
      user = insert(:user, email: "old_email@emcasa.com")

      mutation = """
        mutation {
          changeEmail(id: #{user.id}, email: "newemail@emcasa.com") {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert user = Repo.get(User, user.id)
      assert user.email == "newemail@emcasa.com"
    end

    test "user should change own email", %{user_conn: conn, user_user: user} do
      mutation = """
        mutation {
          changeEmail(id: #{user.id}, email: "newemail@emcasa.com") {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert user = Repo.get(User, user.id)
      assert user.email == "newemail@emcasa.com"
    end

    test "user should not edit other user's  email", %{user_conn: conn} do
      inserted_user = insert(:user)

      mutation = """
        mutation {
          changeEmail(id: #{inserted_user.id}, email: "newemail@emcasa.com") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      mutation = """
        mutation {
          changeEmail(id: #{user.id}, email: "newemail@emcasa.com") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end

    test "should fail when using existing e-mail", %{user_conn: conn, user_user: user} do
      insert(:user, email: "existing@emcasa.com")

      mutation = """
        mutation {
          changeEmail(id: #{user.id}, email: "existing@emcasa.com") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "email has already been taken"}] = json_response(conn, 200)["errors"]
    end
  end

  describe "changePassword" do
    test "admin should change password", %{admin_conn: conn} do
      user = insert(:user)

      mutation = """
        mutation {
          changePassword(id: #{user.id}, currentPassword: "password", newPassword: "newpass") {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert user = Repo.get(User, user.id)
      assert Bcrypt.checkpw("newpass", user.password_hash)
    end

    test "user should change own email", %{user_conn: conn, user_user: user} do
      mutation = """
        mutation {
          changePassword(id: #{user.id}, currentPassword: "password", newPassword: "newpass") {
            id
          }
        }
      """

      post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert user = Repo.get(User, user.id)
      assert Bcrypt.checkpw("newpass", user.password_hash)
    end

    test "user should not edit other user's  email", %{user_conn: conn} do
      inserted_user = insert(:user)

      mutation = """
        mutation {
          changePassword(id: #{inserted_user.id}, currentPassword: "password", newPassword: "newpass") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "Forbidden", "code" => 403}] = json_response(conn, 200)["errors"]
    end

    test "anonymous should not edit user profile", %{unauthenticated_conn: conn} do
      user = insert(:user)

      mutation = """
        mutation {
          changePassword(id: #{user.id}, currentPassword: "password", newPassword: "newpass") {
            id
          }
        }
      """

      conn = post(conn, "/graphql_api", AbsintheHelpers.mutation_skeleton(mutation))

      assert [%{"message" => "Unauthorized", "code" => 401}] = json_response(conn, 200)["errors"]
    end
  end
end
