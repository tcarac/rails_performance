require "test_helper"
require "csv"

module RailsPerformance
  class CsvExportableTest < ActiveSupport::TestCase
    class CsvExporter
      include RailsPerformance::Concerns::CsvExportable
    end

    setup do
      @csv_exporter = CsvExporter.new
      @data = [
        { datetime: "2024-10-25 12:00:00",
          controller_action: "TestController#show", method: "GET", format: "html", path: "/test_path", status: 200, duration: 123.45, views: 67.89, db: 12.34 },
        { datetime: "2024-10-25 12:01:00",
          controller_action: "TestController#edit", method: "POST", format: "json", path: "/test_path", status: 201, duration: 543.21, views: 45.67, db: 8.90 }
      ]
      @headers = ["Datetime", "Controller#action", "Method", "Format", "Path",
                  "Status", "Duration", "Views", "DB"]
    end

    test "generate_csv returns valid CSV content" do
      csv_content = @csv_exporter.send(:generate_csv, @data, @headers)
      parsed_csv = CSV.parse(csv_content, headers: true)

      assert_equal @headers, parsed_csv.headers

      assert_equal 2, parsed_csv.size
      assert_equal "2024-10-25 12:00:00", parsed_csv[0]["Datetime"]
      assert_equal "TestController#show", parsed_csv[0]["Controller#action"]
      assert_equal "GET", parsed_csv[0]["Method"]
      assert_equal "123.45", parsed_csv[0]["Duration"]
    end

    test "export_to_csv does nothing when data is empty" do
      empty_data = []

      @csv_exporter.expects(:send_data).never

      @csv_exporter.export_to_csv("empty_test", empty_data)
    end
  end
end
