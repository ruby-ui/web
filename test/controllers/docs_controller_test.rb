require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get typography" do
    get docs_typography_url
    assert_response :success
  end

  test "data_table with page param passes correct initial data" do
    get docs_data_table_path, params: {page: 2, per_page: 5}
    assert_response :success
    # Page 2, per_page 5 means rows 6-10 are shown initially
    # The data-value should reflect page 2 state
    assert_match "data-ruby-ui--data-table-pagination-value", response.body
    decoded = CGI.unescapeHTML(response.body)
    assert_match '"pageIndex":1', decoded
    assert_match '"pageSize":5', decoded
  end

  test "data_table with search param pre-fills search value" do
    get docs_data_table_path, params: {search: "alice"}
    assert_response :success
    assert_match "data-ruby-ui--data-table-search-value=\"alice\"", response.body
  end

  test "data_table with sort param pre-fills sorting value" do
    get docs_data_table_path, params: {sort: "name", direction: "desc"}
    assert_response :success
    decoded = CGI.unescapeHTML(response.body)
    assert_match '"id":"name"', decoded
    assert_match '"desc":true', decoded
  end
end
