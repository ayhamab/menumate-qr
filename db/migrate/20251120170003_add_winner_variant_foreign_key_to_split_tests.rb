class AddWinnerVariantForeignKeyToSplitTests < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :split_tests, :split_test_variants, column: :winner_variant_id
  end
end

