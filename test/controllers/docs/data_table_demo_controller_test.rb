require "test_helper"

class Docs::DataTableDemoControllerTest < ActionDispatch::IntegrationTest
  test "GET /docs/data_table/demo returns HTML by default" do
    get docs_data_table_demo_path
    assert_response :success
    assert_match "text/html", response.content_type
  end

  test "GET /docs/data_table/demo returns JSON when requested" do
    get docs_data_table_demo_path, headers: { "Accept" => "application/json" }
    assert_response :success
    assert_match "application/json", response.content_type
    json = JSON.parse(response.body)
    assert json.key?("data")
    assert json.key?("row_count")
    assert_kind_of Array, json["data"]
    assert_kind_of Integer, json["row_count"]
  end

  test "JSON response respects page param" do
    get docs_data_table_demo_path, params: { page: 2, per_page: 5 },
                                   headers: { "Accept" => "application/json" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 5, json["data"].length
    assert_equal 30, json["row_count"]
  end

  test "JSON response respects search param" do
    get docs_data_table_demo_path, params: { search: "alice" },
                                   headers: { "Accept" => "application/json" }
    json = JSON.parse(response.body)
    assert json["data"].all? { |r| r["name"].downcase.include?("alice") || r["email"].downcase.include?("alice") }
    assert json["row_count"] < 30
  end
end
