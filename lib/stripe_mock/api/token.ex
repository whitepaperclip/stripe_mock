defmodule StripeMock.API.Token do
  use StripeMock.Schema

  @foreign_key_type :binary_id
  schema "tokens" do
    field :client_ip, :string
    field :created, :integer
    field :type, :string
    field :used, :boolean, default: false

    belongs_to :card, API.Card
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:client_ip, :type])
    |> cast_assoc(:card, with: &API.Card.token_changeset/2)
    |> set_type()
    |> validate_required([:type])
  end

  defp set_type(changeset) do
    case get_field(changeset, :card) do
      nil -> changeset
      _ -> put_change(changeset, :type, "card")
    end
  end
end