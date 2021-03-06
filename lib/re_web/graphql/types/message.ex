defmodule ReWeb.Types.Message do
  @moduledoc """
  GraphQL types for messages
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers.Messages, as: MessagesResolver

  object :message do
    field :id, :id
    field :message, :string
    field :read, :boolean
    field :notified, :boolean
    field :inserted_at, :datetime

    field :sender, :user, resolve: dataloader(Re.Accounts)
    field :receiver, :user, resolve: dataloader(Re.Accounts)
    field :listing, :listing, resolve: dataloader(Re.Listings)
  end

  object :user_messages do
    field :user, :user
    field :messages, list_of(:message)
  end

  object :channel do
    field :id, :id

    field :participant1, :user, resolve: dataloader(Re.Accounts)
    field :participant2, :user, resolve: dataloader(Re.Accounts)
    field :listing, :listing, resolve: dataloader(Re.Listings)

    field :unread_count, :integer, resolve: &MessagesResolver.count_unread/3

    field :messages, list_of(:message) do
      arg :limit, :integer
      arg :offset, :integer

      resolve &MessagesResolver.per_channel/3
    end
  end

  object :message_mutations do
    @desc "Send message"
    field :send_message, type: :message do
      arg :receiver_id, non_null(:id)
      arg :listing_id, non_null(:id)

      arg :message, :string

      resolve &MessagesResolver.send/2
    end

    @desc "Mark message as read"
    field :mark_as_read, type: :message do
      arg :id, non_null(:id)

      resolve &MessagesResolver.mark_as_read/2
    end
  end

  scalar :datetime, name: "DateTime" do
    serialize(&NaiveDateTime.to_iso8601/1)
    parse(&ReWeb.Graphql.SchemaHelpers.parse_datetime/1)
  end
end
