# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_22_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "activity_type", null: false
    t.datetime "created_at", null: false
    t.json "metadata"
    t.integer "restaurant_id", null: false
    t.integer "trackable_id"
    t.string "trackable_type"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["activity_type"], name: "index_activity_logs_on_activity_type"
    t.index ["restaurant_id", "created_at"], name: "index_activity_logs_on_restaurant_id_and_created_at"
    t.index ["restaurant_id"], name: "index_activity_logs_on_restaurant_id"
    t.index ["trackable_type", "trackable_id"], name: "index_activity_logs_on_trackable"
    t.index ["trackable_type", "trackable_id"], name: "index_activity_logs_on_trackable_type_and_trackable_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "api_keys", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0, null: false
    t.integer "user_id", null: false
    t.index ["active"], name: "index_api_keys_on_active"
    t.index ["expires_at"], name: "index_api_keys_on_expires_at"
    t.index ["token"], name: "index_api_keys_on_token", unique: true
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "brand_analytics", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "api_calls_count", default: 0
    t.string "api_key", null: false
    t.string "brand_name", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "last_access_at"
    t.decimal "monthly_fee", precision: 10, scale: 2, default: "0.0"
    t.text "notes"
    t.string "subscription_tier", default: "basic"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_brand_analytics_on_active"
    t.index ["api_key"], name: "index_brand_analytics_on_api_key", unique: true
    t.index ["email"], name: "index_brand_analytics_on_email"
  end

  create_table "brandings", force: :cascade do |t|
    t.string "accent_color", default: "#EC4899"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.text "custom_css"
    t.string "custom_domain"
    t.string "font_family", default: "Inter, system-ui, sans-serif"
    t.boolean "hide_menumate_branding", default: false
    t.string "primary_color", default: "#4F46E5"
    t.integer "restaurant_id", null: false
    t.string "secondary_color", default: "#7C3AED"
    t.string "tagline"
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_brandings_on_restaurant_id"
  end

  create_table "brands", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "brand_color"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "display_order", default: 0, null: false
    t.string "logo_url"
    t.string "name", null: false
    t.integer "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_brands_on_active"
    t.index ["name"], name: "index_brands_on_name"
    t.index ["restaurant_id", "display_order"], name: "index_brands_on_restaurant_id_and_display_order"
    t.index ["restaurant_id"], name: "index_brands_on_restaurant_id"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_categories_on_active"
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "compliance_reports", force: :cascade do |t|
    t.decimal "compliance_percentage", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.text "findings"
    t.text "recommendations"
    t.integer "region_id"
    t.string "report_type", null: false
    t.integer "restaurant_id", null: false
    t.date "shared_at"
    t.boolean "shared_with_restaurant", default: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.text "violations_summary"
    t.index ["compliance_percentage"], name: "index_compliance_reports_on_compliance_percentage"
    t.index ["region_id"], name: "index_compliance_reports_on_region_id"
    t.index ["report_type"], name: "index_compliance_reports_on_report_type"
    t.index ["restaurant_id", "region_id"], name: "index_compliance_reports_on_restaurant_id_and_region_id"
    t.index ["restaurant_id"], name: "index_compliance_reports_on_restaurant_id"
  end

  create_table "consultant_clients", force: :cascade do |t|
    t.boolean "can_edit_menu", default: false
    t.boolean "can_edit_settings", default: false
    t.boolean "can_manage_team", default: false
    t.boolean "can_view", default: true
    t.boolean "can_view_analytics", default: true
    t.integer "consultant_id", null: false
    t.string "contract_type"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.decimal "monthly_fee", precision: 10, scale: 2
    t.text "notes"
    t.integer "restaurant_id", null: false
    t.date "start_date"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.index ["consultant_id", "restaurant_id"], name: "index_consultant_clients_on_consultant_id_and_restaurant_id", unique: true
    t.index ["consultant_id"], name: "index_consultant_clients_on_consultant_id"
    t.index ["restaurant_id"], name: "index_consultant_clients_on_restaurant_id"
    t.index ["status"], name: "index_consultant_clients_on_status"
  end

  create_table "consultant_notes", force: :cascade do |t|
    t.integer "consultant_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "menu_item_id"
    t.string "note_type", null: false
    t.boolean "pinned", default: false
    t.integer "restaurant_id"
    t.text "tags"
    t.datetime "updated_at", null: false
    t.index ["consultant_id", "restaurant_id"], name: "index_consultant_notes_on_consultant_id_and_restaurant_id"
    t.index ["consultant_id"], name: "index_consultant_notes_on_consultant_id"
    t.index ["menu_item_id"], name: "index_consultant_notes_on_menu_item_id"
    t.index ["note_type"], name: "index_consultant_notes_on_note_type"
    t.index ["pinned"], name: "index_consultant_notes_on_pinned"
    t.index ["restaurant_id"], name: "index_consultant_notes_on_restaurant_id"
  end

  create_table "consultant_reports", force: :cascade do |t|
    t.integer "consultant_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.text "findings"
    t.text "recommendations"
    t.string "report_type", null: false
    t.integer "restaurant_id", null: false
    t.date "shared_at"
    t.boolean "shared_with_restaurant", default: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["consultant_id", "restaurant_id"], name: "index_consultant_reports_on_consultant_id_and_restaurant_id"
    t.index ["consultant_id"], name: "index_consultant_reports_on_consultant_id"
    t.index ["report_type"], name: "index_consultant_reports_on_report_type"
    t.index ["restaurant_id"], name: "index_consultant_reports_on_restaurant_id"
    t.index ["shared_with_restaurant"], name: "index_consultant_reports_on_shared_with_restaurant"
  end

  create_table "consultant_tasks", force: :cascade do |t|
    t.date "completed_at"
    t.integer "consultant_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.integer "menu_item_id"
    t.text "notes"
    t.string "priority", default: "medium"
    t.integer "restaurant_id"
    t.string "status", default: "pending"
    t.string "task_type", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["consultant_id", "status"], name: "index_consultant_tasks_on_consultant_id_and_status"
    t.index ["consultant_id"], name: "index_consultant_tasks_on_consultant_id"
    t.index ["due_date"], name: "index_consultant_tasks_on_due_date"
    t.index ["menu_item_id"], name: "index_consultant_tasks_on_menu_item_id"
    t.index ["priority"], name: "index_consultant_tasks_on_priority"
    t.index ["restaurant_id", "status"], name: "index_consultant_tasks_on_restaurant_id_and_status"
    t.index ["restaurant_id"], name: "index_consultant_tasks_on_restaurant_id"
  end

  create_table "consultants", force: :cascade do |t|
    t.text "bio"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "instagram_url"
    t.string "last_name", null: false
    t.string "linkedin_url"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.text "specialties"
    t.string "status", default: "pending"
    t.string "twitter_url"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.string "website"
    t.index ["email"], name: "index_consultants_on_email", unique: true
    t.index ["reset_password_token"], name: "index_consultants_on_reset_password_token", unique: true
    t.index ["status"], name: "index_consultants_on_status"
    t.index ["verified"], name: "index_consultants_on_verified"
  end

  create_table "corporate_account_users", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "corporate_account_id", null: false
    t.datetime "created_at", null: false
    t.string "role", default: "member"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["corporate_account_id", "user_id"], name: "index_corporate_account_users_unique", unique: true
    t.index ["corporate_account_id"], name: "index_corporate_account_users_on_corporate_account_id"
    t.index ["role"], name: "index_corporate_account_users_on_role"
    t.index ["user_id"], name: "index_corporate_account_users_on_user_id"
  end

  create_table "corporate_accounts", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "billing_address"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "max_locations_per_restaurant", default: 50
    t.integer "max_restaurants", default: 10
    t.string "name", null: false
    t.text "notes"
    t.string "phone_number"
    t.string "subscription_tier", default: "enterprise"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_corporate_accounts_on_active"
    t.index ["email"], name: "index_corporate_accounts_on_email"
  end

  create_table "demographic_data", force: :cascade do |t|
    t.text "age_distribution"
    t.datetime "created_at", null: false
    t.text "cultural_preferences"
    t.date "data_date"
    t.string "data_source", null: false
    t.text "dietary_preferences"
    t.text "dining_preferences"
    t.text "income_distribution"
    t.integer "location_id"
    t.text "notes"
    t.string "region_code", null: false
    t.integer "restaurant_id"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.index ["data_source"], name: "index_demographic_data_on_data_source"
    t.index ["location_id"], name: "index_demographic_data_on_location_id"
    t.index ["region_code"], name: "index_demographic_data_on_region_code"
    t.index ["restaurant_id"], name: "index_demographic_data_on_restaurant_id"
    t.index ["verified"], name: "index_demographic_data_on_verified"
  end

  create_table "dietary_accuracy_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "ip_address"
    t.string "issue_type", null: false
    t.integer "menu_item_id", null: false
    t.string "reported_by"
    t.text "resolution_notes"
    t.boolean "resolved", default: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "index_dietary_accuracy_reports_on_created_at"
    t.index ["issue_type"], name: "index_dietary_accuracy_reports_on_issue_type"
    t.index ["menu_item_id"], name: "index_dietary_accuracy_reports_on_menu_item_id"
    t.index ["resolved"], name: "index_dietary_accuracy_reports_on_resolved"
  end

  create_table "dietary_feedbacks", force: :cascade do |t|
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.string "feedback_type", null: false
    t.integer "menu_item_id", null: false
    t.text "message", null: false
    t.text "reported_tags"
    t.text "resolution_notes"
    t.boolean "resolved", default: false
    t.datetime "resolved_at"
    t.integer "resolved_by_id"
    t.integer "restaurant_id", null: false
    t.string "severity", default: "medium"
    t.text "suggested_tags"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["feedback_type"], name: "index_dietary_feedbacks_on_feedback_type"
    t.index ["menu_item_id", "created_at"], name: "index_dietary_feedbacks_on_menu_item_id_and_created_at"
    t.index ["menu_item_id"], name: "index_dietary_feedbacks_on_menu_item_id"
    t.index ["resolved"], name: "index_dietary_feedbacks_on_resolved"
    t.index ["resolved_by_id"], name: "index_dietary_feedbacks_on_resolved_by_id"
    t.index ["restaurant_id", "resolved"], name: "index_dietary_feedbacks_on_restaurant_id_and_resolved"
    t.index ["restaurant_id"], name: "index_dietary_feedbacks_on_restaurant_id"
    t.index ["severity"], name: "index_dietary_feedbacks_on_severity"
    t.index ["user_id"], name: "index_dietary_feedbacks_on_user_id"
  end

  create_table "dietary_laws", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.text "enforcement_notes"
    t.string "law_type", null: false
    t.text "legal_reference"
    t.boolean "mandatory", default: false
    t.string "name", null: false
    t.text "prohibited_ingredients"
    t.text "required_certifications"
    t.text "requirements"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_dietary_laws_on_active"
    t.index ["code"], name: "index_dietary_laws_on_code", unique: true
    t.index ["law_type"], name: "index_dietary_laws_on_law_type"
    t.index ["mandatory"], name: "index_dietary_laws_on_mandatory"
    t.index ["name"], name: "index_dietary_laws_on_name", unique: true
  end

  create_table "dietary_trends", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "dietary_tag", null: false
    t.decimal "growth_rate", precision: 5, scale: 2
    t.json "metadata"
    t.string "region"
    t.integer "sample_size", null: false
    t.date "trend_date", null: false
    t.decimal "trend_percentage", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["dietary_tag", "trend_date", "region"], name: "index_dietary_trends_on_tag_date_region"
    t.index ["dietary_tag"], name: "index_dietary_trends_on_dietary_tag"
    t.index ["region"], name: "index_dietary_trends_on_region"
    t.index ["trend_date"], name: "index_dietary_trends_on_trend_date"
  end

  create_table "ingredient_listing_categories", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "ingredient_listing_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_ingredient_listing_categories_on_category_id"
    t.index ["ingredient_listing_id", "category_id"], name: "index_ingredient_listing_categories_unique", unique: true
    t.index ["ingredient_listing_id"], name: "index_ingredient_listing_categories_on_ingredient_listing_id"
  end

  create_table "ingredient_listings", force: :cascade do |t|
    t.text "certifications"
    t.integer "contact_count", default: 0
    t.datetime "created_at", null: false
    t.text "description"
    t.text "dietary_info"
    t.boolean "featured", default: false
    t.boolean "in_stock", default: true
    t.boolean "local", default: false
    t.decimal "minimum_order_amount", precision: 10, scale: 2
    t.integer "minimum_order_quantity"
    t.string "name", null: false
    t.boolean "organic", default: false
    t.text "packaging_info"
    t.decimal "price_per_unit", precision: 10, scale: 2
    t.text "shelf_life"
    t.string "status", default: "draft"
    t.text "storage_requirements"
    t.integer "supplier_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
    t.index ["featured"], name: "index_ingredient_listings_on_featured"
    t.index ["local"], name: "index_ingredient_listings_on_local"
    t.index ["organic"], name: "index_ingredient_listings_on_organic"
    t.index ["status"], name: "index_ingredient_listings_on_status"
    t.index ["supplier_id", "status"], name: "index_ingredient_listings_on_supplier_id_and_status"
    t.index ["supplier_id"], name: "index_ingredient_listings_on_supplier_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "allergen_type"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "preparation_area"
    t.datetime "updated_at", null: false
    t.index ["allergen_type"], name: "index_ingredients_on_allergen_type"
    t.index ["name"], name: "index_ingredients_on_name", unique: true
    t.index ["preparation_area"], name: "index_ingredients_on_preparation_area"
  end

  create_table "location_menu_overrides", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "approved_at"
    t.integer "approved_by_id"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.integer "location_id", null: false
    t.integer "menu_template_id", null: false
    t.integer "menu_template_item_id"
    t.text "override_attributes"
    t.text "reason"
    t.text "rejection_reason"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_location_menu_overrides_on_action"
    t.index ["approved_by_id"], name: "index_location_menu_overrides_on_approved_by_id"
    t.index ["created_by_id"], name: "index_location_menu_overrides_on_created_by_id"
    t.index ["location_id"], name: "index_location_menu_overrides_on_location_id"
    t.index ["menu_template_id", "location_id"], name: "idx_on_menu_template_id_location_id_13c6d6cbcb"
    t.index ["menu_template_id"], name: "index_location_menu_overrides_on_menu_template_id"
    t.index ["menu_template_item_id", "location_id"], name: "idx_on_menu_template_item_id_location_id_3f040fdc8d"
    t.index ["menu_template_item_id"], name: "index_location_menu_overrides_on_menu_template_item_id"
    t.index ["status"], name: "index_location_menu_overrides_on_status"
  end

  create_table "locations", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "manager_name"
    t.string "name", null: false
    t.text "notes"
    t.string "phone_number"
    t.integer "restaurant_id", null: false
    t.string "timezone", default: "UTC"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_locations_on_active"
    t.index ["restaurant_id"], name: "index_locations_on_restaurant_id"
  end

  create_table "menu_consistency_reports", force: :cascade do |t|
    t.integer "corporate_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.integer "generated_by_id"
    t.integer "menu_template_id"
    t.text "report_data"
    t.string "report_type", null: false
    t.datetime "updated_at", null: false
    t.index ["corporate_account_id", "created_at"], name: "idx_on_corporate_account_id_created_at_e633a3f452"
    t.index ["corporate_account_id"], name: "index_menu_consistency_reports_on_corporate_account_id"
    t.index ["generated_by_id"], name: "index_menu_consistency_reports_on_generated_by_id"
    t.index ["menu_template_id"], name: "index_menu_consistency_reports_on_menu_template_id"
    t.index ["report_type"], name: "index_menu_consistency_reports_on_report_type"
  end

  create_table "menu_item_analytics", force: :cascade do |t|
    t.integer "clicks", default: 0
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "menu_item_id", null: false
    t.integer "orders", default: 0
    t.integer "restaurant_id", null: false
    t.decimal "revenue", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.integer "views", default: 0
    t.index ["date"], name: "index_menu_item_analytics_on_date"
    t.index ["menu_item_id", "date"], name: "index_menu_item_analytics_on_menu_item_id_and_date", unique: true
    t.index ["menu_item_id"], name: "index_menu_item_analytics_on_menu_item_id"
    t.index ["restaurant_id", "date"], name: "index_menu_item_analytics_on_restaurant_id_and_date"
    t.index ["restaurant_id"], name: "index_menu_item_analytics_on_restaurant_id"
  end

  create_table "menu_item_assignments", force: :cascade do |t|
    t.integer "assigned_by_id"
    t.integer "assigned_to_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "due_date"
    t.integer "menu_item_id", null: false
    t.text "notes"
    t.string "priority"
    t.datetime "reviewed_at"
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_menu_item_assignments_on_assigned_by_id"
    t.index ["assigned_to_id"], name: "index_menu_item_assignments_on_assigned_to_id"
    t.index ["menu_item_id"], name: "index_menu_item_assignments_on_menu_item_id"
    t.index ["priority"], name: "index_menu_item_assignments_on_priority"
    t.index ["status"], name: "index_menu_item_assignments_on_status"
  end

  create_table "menu_item_comments", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "menu_item_id", null: false
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["menu_item_id"], name: "index_menu_item_comments_on_menu_item_id"
    t.index ["parent_id"], name: "index_menu_item_comments_on_parent_id"
    t.index ["user_id"], name: "index_menu_item_comments_on_user_id"
  end

  create_table "menu_item_compliances", force: :cascade do |t|
    t.string "certification_number"
    t.boolean "certified", default: false
    t.string "checked_by"
    t.datetime "created_at", null: false
    t.integer "dietary_law_id", null: false
    t.datetime "last_checked_at"
    t.integer "menu_item_id", null: false
    t.text "notes"
    t.integer "region_id"
    t.string "status", default: "pending_review"
    t.datetime "updated_at", null: false
    t.text "violations"
    t.index ["certified"], name: "index_menu_item_compliances_on_certified"
    t.index ["dietary_law_id"], name: "index_menu_item_compliances_on_dietary_law_id"
    t.index ["last_checked_at"], name: "index_menu_item_compliances_on_last_checked_at"
    t.index ["menu_item_id", "dietary_law_id", "region_id"], name: "index_menu_item_compliances_unique", unique: true
    t.index ["menu_item_id"], name: "index_menu_item_compliances_on_menu_item_id"
    t.index ["region_id"], name: "index_menu_item_compliances_on_region_id"
    t.index ["status"], name: "index_menu_item_compliances_on_status"
  end

  create_table "menu_item_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ingredient_id", null: false
    t.integer "menu_item_id", null: false
    t.string "preparation_method"
    t.string "quantity"
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_menu_item_ingredients_on_ingredient_id"
    t.index ["menu_item_id", "ingredient_id"], name: "index_menu_item_ingredients_on_menu_item_id_and_ingredient_id", unique: true
    t.index ["menu_item_id"], name: "index_menu_item_ingredients_on_menu_item_id"
  end

  create_table "menu_item_promotions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "menu_item_id", null: false
    t.integer "promotion_id", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id", "promotion_id"], name: "index_menu_item_promotions_on_menu_item_id_and_promotion_id", unique: true
    t.index ["menu_item_id"], name: "index_menu_item_promotions_on_menu_item_id"
    t.index ["promotion_id"], name: "index_menu_item_promotions_on_promotion_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.text "allergens"
    t.integer "brand_id"
    t.integer "calories"
    t.decimal "carbs", precision: 10, scale: 2
    t.string "category"
    t.integer "cholesterol"
    t.datetime "created_at", null: false
    t.text "description"
    t.text "description_translations"
    t.string "dietary_tags"
    t.decimal "fat", precision: 10, scale: 2
    t.decimal "fiber", precision: 10, scale: 2
    t.integer "location_id"
    t.string "name", null: false
    t.text "name_translations"
    t.string "nutrition_api_provider"
    t.text "nutrition_data"
    t.datetime "nutrition_last_updated"
    t.integer "position", default: 0
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "protein", precision: 10, scale: 2
    t.integer "restaurant_id", null: false
    t.integer "sodium"
    t.decimal "sugar", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_menu_items_on_brand_id"
    t.index ["calories"], name: "index_menu_items_on_calories"
    t.index ["category"], name: "index_menu_items_on_category"
    t.index ["location_id"], name: "index_menu_items_on_location_id"
    t.index ["name"], name: "index_menu_items_on_name"
    t.index ["restaurant_id", "category", "position"], name: "index_menu_items_on_restaurant_id_and_category_and_position"
    t.index ["restaurant_id"], name: "index_menu_items_on_restaurant_id"
  end

  create_table "menu_predictions", force: :cascade do |t|
    t.decimal "actual_value", precision: 10, scale: 4
    t.boolean "actualized", default: false
    t.decimal "confidence_score", precision: 5, scale: 4
    t.datetime "created_at", null: false
    t.integer "demographic_data_id"
    t.text "features"
    t.integer "menu_item_id", null: false
    t.string "model_version"
    t.decimal "predicted_value", precision: 10, scale: 4
    t.text "prediction_details"
    t.string "prediction_type", null: false
    t.integer "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["actualized"], name: "index_menu_predictions_on_actualized"
    t.index ["confidence_score"], name: "index_menu_predictions_on_confidence_score"
    t.index ["demographic_data_id"], name: "index_menu_predictions_on_demographic_data_id"
    t.index ["menu_item_id", "prediction_type", "created_at"], name: "idx_on_menu_item_id_prediction_type_created_at_9b98777bd9"
    t.index ["menu_item_id"], name: "index_menu_predictions_on_menu_item_id"
    t.index ["restaurant_id", "prediction_type"], name: "index_menu_predictions_on_restaurant_id_and_prediction_type"
    t.index ["restaurant_id"], name: "index_menu_predictions_on_restaurant_id"
  end

  create_table "menu_syncs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "initiated_by_id"
    t.integer "location_id", null: false
    t.integer "menu_template_id", null: false
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.text "sync_details"
    t.string "sync_type", default: "full"
    t.datetime "updated_at", null: false
    t.index ["initiated_by_id"], name: "index_menu_syncs_on_initiated_by_id"
    t.index ["location_id"], name: "index_menu_syncs_on_location_id"
    t.index ["menu_template_id", "location_id"], name: "index_menu_syncs_on_menu_template_id_and_location_id"
    t.index ["menu_template_id"], name: "index_menu_syncs_on_menu_template_id"
    t.index ["status"], name: "index_menu_syncs_on_status"
    t.index ["sync_type"], name: "index_menu_syncs_on_sync_type"
  end

  create_table "menu_template_items", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "allergens"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.text "description_translations"
    t.text "dietary_tags"
    t.integer "display_order", default: 0
    t.integer "menu_template_id", null: false
    t.string "name", null: false
    t.text "name_translations"
    t.text "notes"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_menu_template_items_on_active"
    t.index ["category"], name: "index_menu_template_items_on_category"
    t.index ["menu_template_id", "display_order"], name: "idx_on_menu_template_id_display_order_9cb5394e64"
    t.index ["menu_template_id"], name: "index_menu_template_items_on_menu_template_id"
  end

  create_table "menu_templates", force: :cascade do |t|
    t.integer "corporate_account_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "effective_date"
    t.date "expiry_date"
    t.string "name", null: false
    t.text "settings"
    t.string "status", default: "draft"
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["corporate_account_id", "version"], name: "index_menu_templates_on_corporate_account_id_and_version"
    t.index ["corporate_account_id"], name: "index_menu_templates_on_corporate_account_id"
    t.index ["status"], name: "index_menu_templates_on_status"
  end

  create_table "prediction_models", force: :cascade do |t|
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.text "description"
    t.text "feature_importance"
    t.text "model_file_path"
    t.text "model_parameters"
    t.string "model_type", null: false
    t.string "name", null: false
    t.date "trained_at"
    t.text "training_metrics"
    t.integer "training_samples"
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["active"], name: "index_prediction_models_on_active"
    t.index ["model_type"], name: "index_prediction_models_on_model_type"
    t.index ["name", "version"], name: "index_prediction_models_on_name_and_version", unique: true
  end

  create_table "promotions", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "badge_color", default: "red"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "discount_type", null: false
    t.decimal "discount_value", precision: 10, scale: 2
    t.datetime "end_date", null: false
    t.integer "restaurant_id", null: false
    t.datetime "start_date", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_promotions_on_active"
    t.index ["restaurant_id"], name: "index_promotions_on_restaurant_id"
    t.index ["start_date", "end_date"], name: "index_promotions_on_start_date_and_end_date"
  end

  create_table "qr_codes", force: :cascade do |t|
    t.integer "brand_id"
    t.datetime "created_at", null: false
    t.integer "restaurant_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_qr_codes_on_brand_id"
    t.index ["restaurant_id"], name: "index_qr_codes_on_restaurant_id"
    t.index ["token"], name: "index_qr_codes_on_token", unique: true
  end

  create_table "qr_scans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "restaurant_id", null: false
    t.datetime "scanned_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["restaurant_id"], name: "index_qr_scans_on_restaurant_id"
    t.index ["scanned_at"], name: "index_qr_scans_on_scanned_at"
  end

  create_table "ratings", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "menu_item_id", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "index_ratings_on_created_at"
    t.index ["menu_item_id"], name: "index_ratings_on_menu_item_id"
    t.index ["rating"], name: "index_ratings_on_rating"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ingredient_id", null: false
    t.text "notes"
    t.integer "position", default: 0
    t.string "preparation_method"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.integer "recipe_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["position"], name: "index_recipe_ingredients_on_position"
    t.index ["recipe_id", "ingredient_id"], name: "index_recipe_ingredients_on_recipe_id_and_ingredient_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "base_servings", default: 1, null: false
    t.integer "cook_time"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "difficulty"
    t.text "instructions"
    t.integer "menu_item_id"
    t.string "name", null: false
    t.text "notes"
    t.integer "prep_time"
    t.integer "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_recipes_on_menu_item_id"
    t.index ["restaurant_id", "name"], name: "index_recipes_on_restaurant_id_and_name"
    t.index ["restaurant_id"], name: "index_recipes_on_restaurant_id"
  end

  create_table "region_dietary_laws", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dietary_law_id", null: false
    t.date "effective_date"
    t.string "enforcement_level", default: "mandatory"
    t.date "expiry_date"
    t.text "notes"
    t.integer "region_id", null: false
    t.datetime "updated_at", null: false
    t.index ["dietary_law_id"], name: "index_region_dietary_laws_on_dietary_law_id"
    t.index ["enforcement_level"], name: "index_region_dietary_laws_on_enforcement_level"
    t.index ["region_id", "dietary_law_id"], name: "index_region_dietary_laws_on_region_id_and_dietary_law_id", unique: true
    t.index ["region_id"], name: "index_region_dietary_laws_on_region_id"
  end

  create_table "regions", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "code", null: false
    t.text "compliance_notes"
    t.string "country_code", limit: 2, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "parent_region_code"
    t.string "region_type", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_regions_on_active"
    t.index ["code"], name: "index_regions_on_code", unique: true
    t.index ["country_code"], name: "index_regions_on_country_code"
    t.index ["name"], name: "index_regions_on_name", unique: true
    t.index ["region_type"], name: "index_regions_on_region_type"
  end

  create_table "restaurant_regions", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "compliance_notes"
    t.datetime "created_at", null: false
    t.integer "region_id", null: false
    t.date "registered_date"
    t.integer "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_restaurant_regions_on_active"
    t.index ["region_id"], name: "index_restaurant_regions_on_region_id"
    t.index ["restaurant_id", "region_id"], name: "index_restaurant_regions_on_restaurant_id_and_region_id", unique: true
    t.index ["restaurant_id"], name: "index_restaurant_regions_on_restaurant_id"
  end

  create_table "restaurant_teams", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "restaurant_id", null: false
    t.string "role", default: "staff"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["active"], name: "index_restaurant_teams_on_active"
    t.index ["restaurant_id", "user_id"], name: "index_restaurant_teams_unique", unique: true
    t.index ["restaurant_id"], name: "index_restaurant_teams_on_restaurant_id"
    t.index ["role"], name: "index_restaurant_teams_on_role"
    t.index ["user_id"], name: "index_restaurant_teams_on_user_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "address", null: false
    t.integer "corporate_account_id"
    t.datetime "created_at", null: false
    t.string "cuisine"
    t.text "description"
    t.string "name", null: false
    t.string "phone_number"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["corporate_account_id"], name: "index_restaurants_on_corporate_account_id"
    t.index ["cuisine"], name: "index_restaurants_on_cuisine"
    t.index ["name"], name: "index_restaurants_on_name"
    t.index ["user_id"], name: "index_restaurants_on_user_id"
  end

  create_table "seasonal_menu_schedules", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.time "end_time"
    t.integer "menu_item_id", null: false
    t.string "name", null: false
    t.boolean "recurring", default: false, null: false
    t.string "recurring_pattern"
    t.integer "restaurant_id", null: false
    t.date "start_date", null: false
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_seasonal_menu_schedules_on_active"
    t.index ["end_date"], name: "index_seasonal_menu_schedules_on_end_date"
    t.index ["menu_item_id"], name: "index_seasonal_menu_schedules_on_menu_item_id"
    t.index ["restaurant_id", "menu_item_id"], name: "idx_on_restaurant_id_menu_item_id_484b9059a5"
    t.index ["restaurant_id"], name: "index_seasonal_menu_schedules_on_restaurant_id"
    t.index ["start_date", "end_date", "active"], name: "index_seasonal_schedules_on_dates_and_active"
    t.index ["start_date"], name: "index_seasonal_menu_schedules_on_start_date"
  end

  create_table "split_test_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "ip_address"
    t.decimal "revenue", precision: 10, scale: 2
    t.string "session_id", null: false
    t.integer "split_test_id", null: false
    t.integer "split_test_variant_id", null: false
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.index ["created_at"], name: "index_split_test_results_on_created_at"
    t.index ["session_id"], name: "index_split_test_results_on_session_id"
    t.index ["split_test_id", "event_type"], name: "index_split_test_results_on_split_test_id_and_event_type"
    t.index ["split_test_id"], name: "index_split_test_results_on_split_test_id"
    t.index ["split_test_variant_id", "event_type"], name: "idx_on_split_test_variant_id_event_type_c815f79fa7"
    t.index ["split_test_variant_id"], name: "index_split_test_results_on_split_test_variant_id"
  end

  create_table "split_test_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_control", default: false
    t.string "name", null: false
    t.text "notes"
    t.integer "position"
    t.decimal "price", precision: 10, scale: 2
    t.integer "split_test_id", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 50
    t.index ["split_test_id", "is_control"], name: "index_split_test_variants_on_split_test_id_and_is_control"
    t.index ["split_test_id"], name: "index_split_test_variants_on_split_test_id"
    t.index ["weight"], name: "index_split_test_variants_on_weight"
  end

  create_table "split_tests", force: :cascade do |t|
    t.boolean "auto_apply_winner", default: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "menu_item_id"
    t.string "name", null: false
    t.text "notes"
    t.integer "restaurant_id", null: false
    t.datetime "started_at"
    t.string "status", default: "draft"
    t.string "test_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "winner_variant_id"
    t.index ["menu_item_id"], name: "index_split_tests_on_menu_item_id"
    t.index ["restaurant_id", "status"], name: "index_split_tests_on_restaurant_id_and_status"
    t.index ["restaurant_id"], name: "index_split_tests_on_restaurant_id"
    t.index ["status"], name: "index_split_tests_on_status"
    t.index ["test_type"], name: "index_split_tests_on_test_type"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.boolean "cancel_at_period_end", default: false
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.string "plan_name", default: "basic", null: false
    t.integer "restaurant_id", null: false
    t.string "status", default: "incomplete", null: false
    t.string "stripe_customer_id"
    t.string "stripe_price_id"
    t.string "stripe_subscription_id"
    t.datetime "updated_at", null: false
    t.index ["plan_name"], name: "index_subscriptions_on_plan_name"
    t.index ["restaurant_id"], name: "index_subscriptions_on_restaurant_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "supplier_contacts", force: :cascade do |t|
    t.string "contact_type", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "ingredient_listing_id"
    t.text "message", null: false
    t.string "name", null: false
    t.string "phone_number"
    t.boolean "read", default: false
    t.datetime "read_at"
    t.integer "restaurant_id"
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_type"], name: "index_supplier_contacts_on_contact_type"
    t.index ["ingredient_listing_id"], name: "index_supplier_contacts_on_ingredient_listing_id"
    t.index ["restaurant_id"], name: "index_supplier_contacts_on_restaurant_id"
    t.index ["supplier_id", "read"], name: "index_supplier_contacts_on_supplier_id_and_read"
    t.index ["supplier_id"], name: "index_supplier_contacts_on_supplier_id"
  end

  create_table "supplier_promotion_targets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "restaurant_id", null: false
    t.integer "supplier_promotion_id", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_supplier_promotion_targets_on_restaurant_id"
    t.index ["supplier_promotion_id", "restaurant_id"], name: "index_supplier_promotion_targets_unique", unique: true
    t.index ["supplier_promotion_id"], name: "index_supplier_promotion_targets_on_supplier_promotion_id"
  end

  create_table "supplier_promotions", force: :cascade do |t|
    t.integer "click_count", default: 0
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "discount_amount", precision: 10, scale: 2
    t.decimal "discount_percentage", precision: 5, scale: 2
    t.date "end_date", null: false
    t.boolean "featured", default: false
    t.string "promotion_type", null: false
    t.date "start_date", null: false
    t.string "status", default: "draft"
    t.integer "supplier_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
    t.index ["featured"], name: "index_supplier_promotions_on_featured"
    t.index ["start_date", "end_date"], name: "index_supplier_promotions_on_start_date_and_end_date"
    t.index ["status"], name: "index_supplier_promotions_on_status"
    t.index ["supplier_id", "status"], name: "index_supplier_promotions_on_supplier_id_and_status"
    t.index ["supplier_id"], name: "index_supplier_promotions_on_supplier_id"
  end

  create_table "supplier_reviews", force: :cascade do |t|
    t.boolean "approved", default: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.integer "restaurant_id", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_supplier_reviews_on_approved"
    t.index ["rating"], name: "index_supplier_reviews_on_rating"
    t.index ["restaurant_id"], name: "index_supplier_reviews_on_restaurant_id"
    t.index ["supplier_id", "restaurant_id"], name: "index_supplier_reviews_on_supplier_id_and_restaurant_id", unique: true
    t.index ["supplier_id"], name: "index_supplier_reviews_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.text "address", null: false
    t.string "business_type"
    t.text "certifications"
    t.string "city"
    t.string "company_name", null: false
    t.string "contact_name", null: false
    t.string "country", default: "US"
    t.datetime "created_at", null: false
    t.text "delivery_areas"
    t.text "description"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "facebook_url"
    t.boolean "featured", default: false
    t.string "instagram_url"
    t.string "linkedin_url"
    t.decimal "minimum_order_amount", precision: 10, scale: 2
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.text "specialties"
    t.string "state"
    t.string "status", default: "pending"
    t.string "twitter_url"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.string "website"
    t.string "zip_code"
    t.index ["business_type"], name: "index_suppliers_on_business_type"
    t.index ["email"], name: "index_suppliers_on_email", unique: true
    t.index ["featured"], name: "index_suppliers_on_featured"
    t.index ["reset_password_token"], name: "index_suppliers_on_reset_password_token", unique: true
    t.index ["status"], name: "index_suppliers_on_status"
    t.index ["verified"], name: "index_suppliers_on_verified"
  end

  create_table "training_answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_correct"
    t.json "selected_option"
    t.integer "training_question_id", null: false
    t.integer "training_session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["training_question_id"], name: "index_training_answers_on_training_question_id"
    t.index ["training_session_id", "training_question_id"], name: "idx_on_training_session_id_training_question_id_767469a250", unique: true
    t.index ["training_session_id"], name: "index_training_answers_on_training_session_id"
  end

  create_table "training_completions", force: :cascade do |t|
    t.boolean "certified", default: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "restaurant_id"
    t.decimal "score", precision: 5, scale: 2
    t.integer "training_module_id", null: false
    t.integer "training_session_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["restaurant_id", "certified"], name: "index_training_completions_on_restaurant_id_and_certified"
    t.index ["restaurant_id"], name: "index_training_completions_on_restaurant_id"
    t.index ["training_module_id"], name: "index_training_completions_on_training_module_id"
    t.index ["training_session_id"], name: "index_training_completions_on_training_session_id"
    t.index ["user_id", "training_module_id"], name: "index_training_completions_on_user_id_and_training_module_id"
    t.index ["user_id"], name: "index_training_completions_on_user_id"
  end

  create_table "training_modules", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "certification_valid_days"
    t.text "content"
    t.datetime "created_at", null: false
    t.text "description"
    t.text "learning_objectives"
    t.string "module_type", null: false
    t.text "notes"
    t.integer "passing_score", default: 80
    t.integer "position", default: 0
    t.boolean "required", default: false
    t.integer "restaurant_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_training_modules_on_active"
    t.index ["position"], name: "index_training_modules_on_position"
    t.index ["required"], name: "index_training_modules_on_required"
    t.index ["restaurant_id", "module_type"], name: "index_training_modules_on_restaurant_id_and_module_type"
    t.index ["restaurant_id"], name: "index_training_modules_on_restaurant_id"
  end

  create_table "training_questions", force: :cascade do |t|
    t.json "correct_option"
    t.datetime "created_at", null: false
    t.text "explanation"
    t.text "hint"
    t.json "options"
    t.integer "position", default: 0
    t.text "question_text", null: false
    t.string "question_type", null: false
    t.integer "training_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["training_module_id", "position"], name: "index_training_questions_on_training_module_id_and_position"
    t.index ["training_module_id"], name: "index_training_questions_on_training_module_id"
  end

  create_table "training_sessions", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "restaurant_id"
    t.decimal "score", precision: 5, scale: 2
    t.datetime "started_at"
    t.string "status", default: "in_progress"
    t.integer "time_spent_seconds"
    t.integer "training_module_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["restaurant_id", "status"], name: "index_training_sessions_on_restaurant_id_and_status"
    t.index ["restaurant_id"], name: "index_training_sessions_on_restaurant_id"
    t.index ["status"], name: "index_training_sessions_on_status"
    t.index ["training_module_id"], name: "index_training_sessions_on_training_module_id"
    t.index ["user_id", "training_module_id"], name: "index_training_sessions_on_user_id_and_training_module_id"
    t.index ["user_id"], name: "index_training_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "restaurants"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "api_keys", "users"
  add_foreign_key "brandings", "restaurants"
  add_foreign_key "brands", "restaurants"
  add_foreign_key "compliance_reports", "regions"
  add_foreign_key "compliance_reports", "restaurants"
  add_foreign_key "consultant_clients", "consultants"
  add_foreign_key "consultant_clients", "restaurants"
  add_foreign_key "consultant_notes", "consultants"
  add_foreign_key "consultant_notes", "menu_items"
  add_foreign_key "consultant_notes", "restaurants"
  add_foreign_key "consultant_reports", "consultants"
  add_foreign_key "consultant_reports", "restaurants"
  add_foreign_key "consultant_tasks", "consultants"
  add_foreign_key "consultant_tasks", "menu_items"
  add_foreign_key "consultant_tasks", "restaurants"
  add_foreign_key "corporate_account_users", "corporate_accounts"
  add_foreign_key "corporate_account_users", "users"
  add_foreign_key "demographic_data", "locations"
  add_foreign_key "demographic_data", "restaurants"
  add_foreign_key "dietary_accuracy_reports", "menu_items"
  add_foreign_key "dietary_feedbacks", "menu_items"
  add_foreign_key "dietary_feedbacks", "restaurants"
  add_foreign_key "dietary_feedbacks", "users"
  add_foreign_key "dietary_feedbacks", "users", column: "resolved_by_id"
  add_foreign_key "ingredient_listing_categories", "categories"
  add_foreign_key "ingredient_listing_categories", "ingredient_listings"
  add_foreign_key "ingredient_listings", "suppliers"
  add_foreign_key "location_menu_overrides", "locations"
  add_foreign_key "location_menu_overrides", "menu_template_items"
  add_foreign_key "location_menu_overrides", "menu_templates"
  add_foreign_key "location_menu_overrides", "users", column: "approved_by_id"
  add_foreign_key "location_menu_overrides", "users", column: "created_by_id"
  add_foreign_key "locations", "restaurants"
  add_foreign_key "menu_consistency_reports", "corporate_accounts"
  add_foreign_key "menu_consistency_reports", "menu_templates"
  add_foreign_key "menu_consistency_reports", "users", column: "generated_by_id"
  add_foreign_key "menu_item_analytics", "menu_items"
  add_foreign_key "menu_item_analytics", "restaurants"
  add_foreign_key "menu_item_assignments", "menu_items"
  add_foreign_key "menu_item_assignments", "users", column: "assigned_by_id"
  add_foreign_key "menu_item_assignments", "users", column: "assigned_to_id"
  add_foreign_key "menu_item_comments", "menu_item_comments", column: "parent_id"
  add_foreign_key "menu_item_comments", "menu_items"
  add_foreign_key "menu_item_comments", "users"
  add_foreign_key "menu_item_compliances", "dietary_laws"
  add_foreign_key "menu_item_compliances", "menu_items"
  add_foreign_key "menu_item_compliances", "regions"
  add_foreign_key "menu_item_ingredients", "ingredients"
  add_foreign_key "menu_item_ingredients", "menu_items"
  add_foreign_key "menu_item_promotions", "menu_items"
  add_foreign_key "menu_item_promotions", "promotions"
  add_foreign_key "menu_items", "brands"
  add_foreign_key "menu_items", "locations"
  add_foreign_key "menu_items", "restaurants"
  add_foreign_key "menu_predictions", "demographic_data", column: "demographic_data_id"
  add_foreign_key "menu_predictions", "menu_items"
  add_foreign_key "menu_predictions", "restaurants"
  add_foreign_key "menu_syncs", "locations"
  add_foreign_key "menu_syncs", "menu_templates"
  add_foreign_key "menu_syncs", "users", column: "initiated_by_id"
  add_foreign_key "menu_template_items", "menu_templates"
  add_foreign_key "menu_templates", "corporate_accounts"
  add_foreign_key "promotions", "restaurants"
  add_foreign_key "qr_codes", "brands"
  add_foreign_key "qr_codes", "restaurants"
  add_foreign_key "qr_scans", "restaurants"
  add_foreign_key "ratings", "menu_items"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipes", "menu_items"
  add_foreign_key "recipes", "restaurants"
  add_foreign_key "region_dietary_laws", "dietary_laws"
  add_foreign_key "region_dietary_laws", "regions"
  add_foreign_key "restaurant_regions", "regions"
  add_foreign_key "restaurant_regions", "restaurants"
  add_foreign_key "restaurant_teams", "restaurants"
  add_foreign_key "restaurant_teams", "users"
  add_foreign_key "restaurants", "corporate_accounts"
  add_foreign_key "restaurants", "users"
  add_foreign_key "seasonal_menu_schedules", "menu_items"
  add_foreign_key "seasonal_menu_schedules", "restaurants"
  add_foreign_key "split_test_results", "split_test_variants"
  add_foreign_key "split_test_results", "split_tests"
  add_foreign_key "split_test_variants", "split_tests"
  add_foreign_key "split_tests", "menu_items"
  add_foreign_key "split_tests", "restaurants"
  add_foreign_key "split_tests", "split_test_variants", column: "winner_variant_id"
  add_foreign_key "subscriptions", "restaurants"
  add_foreign_key "supplier_contacts", "ingredient_listings"
  add_foreign_key "supplier_contacts", "restaurants"
  add_foreign_key "supplier_contacts", "suppliers"
  add_foreign_key "supplier_promotion_targets", "restaurants"
  add_foreign_key "supplier_promotion_targets", "supplier_promotions"
  add_foreign_key "supplier_promotions", "suppliers"
  add_foreign_key "supplier_reviews", "restaurants"
  add_foreign_key "supplier_reviews", "suppliers"
  add_foreign_key "training_answers", "training_questions"
  add_foreign_key "training_answers", "training_sessions"
  add_foreign_key "training_completions", "restaurants"
  add_foreign_key "training_completions", "training_modules"
  add_foreign_key "training_completions", "training_sessions"
  add_foreign_key "training_completions", "users"
  add_foreign_key "training_modules", "restaurants"
  add_foreign_key "training_questions", "training_modules"
  add_foreign_key "training_sessions", "restaurants"
  add_foreign_key "training_sessions", "training_modules"
  add_foreign_key "training_sessions", "users"
end
