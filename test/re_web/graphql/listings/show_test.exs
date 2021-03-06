defmodule ReWeb.GraphQL.Listings.ShowTest do
  use ReWeb.ConnCase

  import Re.Factory

  alias ReWeb.AbsintheHelpers

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

  test "admin should query listing show", %{admin_conn: conn} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street, street_number: street_number} = address = insert(:address)
    user = insert(:user)
    interests = insert_list(3, :interest)
    in_person_visits = insert_list(3, :in_person_visit)
    listings_favorites = insert_list(3, :listings_favorites)
    tour_visualisations = insert_list(3, :tour_visualisation)
    listings_visualisations = insert_list(3, :listing_visualisation)
    price_history = insert_list(3, :price_history)

    insert(
      :factors,
      street: street,
      intercept: 10.10,
      rooms: 123.321,
      area: 321.123,
      bathrooms: 111.222,
      garage_spots: 222.111
    )

    %{id: listing_id} =
      insert(
        :listing,
        address: address,
        images: active_images ++ inactive_images,
        user: user,
        interests: interests,
        in_person_visits: in_person_visits,
        listings_favorites: listings_favorites,
        tour_visualisations: tour_visualisations,
        listings_visualisations: listings_visualisations,
        price_history: price_history,
        rooms: 2,
        area: 80,
        garage_spots: 1,
        bathrooms: 1
      )

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
            street_number
          }
          activeImages: images (isActive: true) {
            filename
          }
          inactiveImages: images (isActive: false) {
            filename
          }
          owner {
            name
          }
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
          previousPrices {
            price
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    name = user.name

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => ^street_number},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _],
               "owner" => %{"name" => ^name},
               "interestCount" => 3,
               "inPersonVisitCount" => 3,
               "listingFavoriteCount" => 3,
               "tourVisualisationCount" => 3,
               "listingVisualisationCount" => 3,
               "previousPrices" => [%{"price" => _}, %{"price" => _}, %{"price" => _}],
               "suggestedPrice" => 26_279.915
             }
           } = json_response(conn, 200)["data"]
  end

  test "owner should query listing show", %{user_conn: conn, user_user: user} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street, street_number: street_number} = address = insert(:address)

    interests = insert_list(3, :interest)
    in_person_visits = insert_list(3, :in_person_visit)
    listings_favorites = insert_list(3, :listings_favorites)
    tour_visualisations = insert_list(3, :tour_visualisation)
    listings_visualisations = insert_list(3, :listing_visualisation)
    price_history = insert_list(3, :price_history)

    %{id: listing_id} =
      insert(
        :listing,
        address: address,
        images: active_images ++ inactive_images,
        user: user,
        interests: interests,
        in_person_visits: in_person_visits,
        listings_favorites: listings_favorites,
        tour_visualisations: tour_visualisations,
        listings_visualisations: listings_visualisations,
        price_history: price_history
      )

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
            street_number
          }
          activeImages: images (isActive: true) {
            filename
          }
          inactiveImages: images (isActive: false) {
            filename
          }
          owner {
            name
          }
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
          previousPrices {
            price
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    name = user.name

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => ^street_number},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _],
               "owner" => %{"name" => ^name},
               "interestCount" => 3,
               "inPersonVisitCount" => 3,
               "listingFavoriteCount" => 3,
               "tourVisualisationCount" => 3,
               "listingVisualisationCount" => 3,
               "previousPrices" => [%{"price" => _}, %{"price" => _}, %{"price" => _}],
               "suggestedPrice" => nil
             }
           } = json_response(conn, 200)["data"]
  end

  test "user should query listing show", %{user_conn: conn} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street} = address = insert(:address)
    user = insert(:user)

    %{id: listing_id} =
      insert(:listing, address: address, images: active_images ++ inactive_images, user: user)

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
            street_number
          }
          activeImages: images (isActive: true) {
            filename
          }
          inactiveImages: images (isActive: false) {
            filename
          }
          owner {
            name
          }
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
          previousPrices {
            price
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => nil},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _, _],
               "owner" => nil,
               "interestCount" => nil,
               "inPersonVisitCount" => nil,
               "listingFavoriteCount" => nil,
               "tourVisualisationCount" => nil,
               "listingVisualisationCount" => nil,
               "previousPrices" => nil,
               "suggestedPrice" => nil
             }
           } = json_response(conn, 200)["data"]
  end

  test "anonymous should query listing show", %{unauthenticated_conn: conn} do
    active_images = insert_list(3, :image, is_active: true)
    inactive_images = insert_list(2, :image, is_active: false)
    %{street: street} = address = insert(:address)
    user = insert(:user)

    %{id: listing_id} =
      insert(:listing, address: address, images: active_images ++ inactive_images, user: user)

    query = """
      {
        listing (id: #{listing_id}) {
          address {
            street
            street_number
          }
          activeImages: images (isActive: true) {
            filename
          }
          inactiveImages: images (isActive: false) {
            filename
          }
          owner {
            name
          }
          interestCount
          inPersonVisitCount
          listingFavoriteCount
          tourVisualisationCount
          listingVisualisationCount
          previousPrices {
            price
          }
          suggestedPrice
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    assert %{
             "listing" => %{
               "address" => %{"street" => ^street, "street_number" => nil},
               "activeImages" => [_, _, _],
               "inactiveImages" => [_, _, _],
               "owner" => nil,
               "interestCount" => nil,
               "inPersonVisitCount" => nil,
               "listingFavoriteCount" => nil,
               "tourVisualisationCount" => nil,
               "listingVisualisationCount" => nil,
               "previousPrices" => nil,
               "suggestedPrice" => nil
             }
           } = json_response(conn, 200)["data"]
  end

  test "admin should see inactive listing", %{admin_conn: conn} do
    %{id: listing_id} = insert(:listing, is_active: false)

    query = """
      {
        listing (id: #{listing_id}) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    listing_id = to_string(listing_id)

    assert %{"listing" => %{"id" => ^listing_id}} = json_response(conn, 200)["data"]
  end

  test "owner should see inactive listing", %{user_conn: conn, user_user: user} do
    %{id: listing_id} = insert(:listing, is_active: false, user: user)

    query = """
      {
        listing (id: #{listing_id}) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    listing_id = to_string(listing_id)

    assert %{"listing" => %{"id" => ^listing_id}} = json_response(conn, 200)["data"]
  end

  test "user should not see inactive listing", %{user_conn: conn} do
    %{id: listing_id} = insert(:listing, is_active: false)

    query = """
      {
        listing (id: #{listing_id}) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    assert [%{"message" => "Not found", "code" => 404}] = json_response(conn, 200)["errors"]
  end

  test "anonymous should not see inactive listing", %{unauthenticated_conn: conn} do
    %{id: listing_id} = insert(:listing, is_active: false)

    query = """
      {
        listing (id: #{listing_id}) {
          id
        }
      }
    """

    conn = post(conn, "/graphql_api", AbsintheHelpers.query_skeleton(query, "listing"))

    assert [%{"message" => "Not found", "code" => 404}] = json_response(conn, 200)["errors"]
  end
end
