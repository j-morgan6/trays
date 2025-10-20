defmodule Trays.Repo.Migrations.UpdateExistingMerchantLocationsContactInfo do
  use Ecto.Migration

  def up do
    execute """
    UPDATE merchant_locations
    SET email = 'apd81front@gmail.com', phone_number = '416-555-0181'
    WHERE street1 = '81 Front Street E'
    """

    execute """
    UPDATE merchant_locations
    SET email = 'apd222bay@gmail.com', phone_number = '416-555-0222'
    WHERE street1 = '222 Bay'
    """
  end

  def down do
    execute """
    UPDATE merchant_locations
    SET email = NULL, phone_number = NULL
    WHERE street1 IN ('81 Front Street E', '222 Bay')
    """
  end
end
