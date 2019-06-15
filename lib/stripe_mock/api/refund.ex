defmodule StripeMock.API.Refund do
  use StripeMock.Schema
  alias StripeMock.Repo

  @foreign_key_type :binary_id
  schema "refunds" do
    field :amount, :integer
    field :created, :integer
    field :metadata, StripeMock.Type.Metadata, default: %{}
    field :reason, :string

    belongs_to :charge, API.Charge
  end

  @doc false
  def create_changeset(refund, attrs) do
    refund
    |> cast(attrs, [:charge_id, :amount, :metadata, :reason])
    |> validate_required([:charge_id])
    |> set_default_amount()
    |> validate_required(:amount)
    |> validate_amount()
    |> validate_reason()
  end

  @doc false
  def update_changeset(refund, attrs) do
    refund
    |> cast(attrs, [:metadata])
  end

  defp set_default_amount(changeset) do
    with nil <- get_field(changeset, :amount),
         {:ok, charge} <- fetch_charge(changeset) do
      put_change(changeset, :amount, charge.amount)
    else
      _ -> changeset
    end
  end

  defp validate_amount(changeset) do
    with {:ok, charge} <- fetch_charge(changeset),
         amount when is_integer(amount) <- get_field(changeset, :amount) do
      total_refunded =
        __MODULE__
        |> Repo.all()
        |> Enum.filter(&(&1.charge_id == charge.id))
        |> Enum.map(& &1.amount)
        |> Enum.sum()

      if total_refunded + amount > charge.amount do
        add_error(changeset, :amount, "is too high")
      else
        changeset
      end
    else
      _ -> changeset
    end
  end

  defp validate_reason(changeset) do
    case get_field(changeset, :reason) do
      nil -> changeset
      reason when reason in ~w(duplicate fraudulent requested_by_customer) -> changeset
      _ -> add_error(changeset, :reason, "is invalid")
    end
  end

  defp fetch_charge(changeset) do
    with charge_id when is_bitstring(charge_id) <- get_field(changeset, :charge_id),
         {:ok, _} = result <- Repo.fetch(API.Charge, charge_id) do
      result
    else
      _ -> nil
    end
  end
end