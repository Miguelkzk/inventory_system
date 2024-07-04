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

ActiveRecord::Schema[7.1].define(version: 2024_06_14_021050) do
  create_table "article_providers", force: :cascade do |t|
    t.integer "article_id"
    t.integer "provider_id"
    t.integer "lead_time"
    t.decimal "order_cost"
    t.decimal "purchase_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_providers_on_article_id"
    t.index ["provider_id"], name: "index_article_providers_on_provider_id"
  end

  create_table "article_sales", force: :cascade do |t|
    t.integer "article_id"
    t.integer "sale_id"
    t.integer "quantity"
    t.datetime "sold_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_sales_on_article_id"
    t.index ["sale_id"], name: "index_article_sales_on_sale_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.decimal "annual_storage_cost"
    t.integer "stock"
    t.integer "inventory_model"
    t.integer "default_provider_id"
    t.integer "revision_interval_days_count"
    t.integer "estimated_demand"
    t.integer "annual_demand_standard_deviation"
    t.integer "demand_period_count"
    t.integer "demand_period_kind"
    t.integer "demand_error_calculation_method"
    t.decimal "demand_acceptable_error"
    t.integer "service_level"
    t.datetime "stock_will_be_checked_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_articles_on_deleted_at"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer "state"
    t.integer "quantity"
    t.integer "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_purchase_orders_on_article_id"
  end

  create_table "sales", force: :cascade do |t|
    t.datetime "sold_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
