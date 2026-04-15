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

  test "docs data_table page includes pagination data-value" do
    get docs_data_table_path
    assert_response :success
    assert_match "data-ruby-ui--data-table-pagination-value", response.body
    decoded = CGI.unescapeHTML(response.body)
    assert_match '"pageIndex":0', decoded
    assert_match '"pageSize":10', decoded
  end

  test "JSON response respects sort param ascending" do
    get docs_data_table_demo_path, params: {sort: "name", direction: "asc"},
                                   headers: {"Accept" => "application/json"}
    json = JSON.parse(response.body)
    names = json["data"].map { |r| r["name"] }
    assert_equal names.sort, names
  end

  test "JSON response respects sort param descending" do
    get docs_data_table_demo_path, params: {sort: "name", direction: "desc"},
                                   headers: {"Accept" => "application/json"}
    json = JSON.parse(response.body)
    names = json["data"].map { |r| r["name"] }
    assert_equal names.sort.reverse, names
  end
end
