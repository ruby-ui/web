# frozen_string_literal: true

require "test_helper"

class Docs::DataTableDemoControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns 200" do
    get docs_data_table_demo_url
    assert_response :success
  end

  test "GET index with ?search= filters employees" do
    get docs_data_table_demo_url(search: "alice")
    assert_response :success
    assert_match(/Alice Johnson/, response.body)
    assert_no_match(/Bob Smith/, response.body)
  end

  test "GET index with ?sort=name&direction=desc sorts" do
    get docs_data_table_demo_url(sort: "name", direction: "desc", per_page: 100)
    alice_at = response.body.index("Alice Johnson")
    violet_at = response.body.index("Violet Fisher")
    assert violet_at < alice_at, "Violet should appear before Alice when sorted desc"
  end

  test "GET index with ?sort=salary sorts numerically" do
    get docs_data_table_demo_url(sort: "salary", direction: "asc", per_page: 5)
    assert_match(/Grace Lee/, response.body)
  end

  test "GET index paginates" do
    get docs_data_table_demo_url(page: 2, per_page: 5)
    assert_response :success
  end

  test "POST bulk_delete with ids[] redirects + flashes" do
    post docs_data_table_demo_bulk_delete_url, params: {ids: ["1", "2"]}
    assert_redirected_to docs_data_table_demo_path
    follow_redirect!
    assert_match(/Would delete: 1, 2/, response.body)
  end

  test "POST bulk_export with ids[] redirects + flashes" do
    post docs_data_table_demo_bulk_export_url, params: {ids: ["3"]}
    assert_redirected_to docs_data_table_demo_path
  end

  test "GET index renders row checkboxes with ids[] name" do
    get docs_data_table_demo_url(per_page: 5)
    assert_match(/name="ids\[\]"[^>]*value="1"|value="1"[^>]*name="ids\[\]"/, response.body)
  end
end
