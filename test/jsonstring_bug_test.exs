defmodule AshGraphql.JsonStringBugTest do
  use ExUnit.Case, async: false

  describe "JSONString bug demonstration and fix" do
    test "v1.8.3 behavior: struct with instance_of works for output but not input" do
      # This test demonstrates v1.8.3 behavior
      # The !input? check on line 4940 means only output types work
      struct_attribute = %{
        type: Ash.Type.Struct,
        constraints: [instance_of: AshGraphql.Test.Post],
        name: :post_struct,
        allow_nil?: false
      }

      # Test output type generation
      output_type = AshGraphql.Resource.field_type(
        struct_attribute.type,
        struct_attribute,
        AshGraphql.Test.User,
        false
      )

      # Test input type generation
      input_type = AshGraphql.Resource.field_type(
        struct_attribute.type,
        struct_attribute,
        AshGraphql.Test.User,
        true
      )

      IO.puts("GraphQL resource - Output type: #{inspect(output_type)}")
      IO.puts("GraphQL resource - Input type: #{inspect(input_type)}")

      # v1.8.3 behavior:
      # Output correctly returns :post (working as intended)
      # Input returns :json_string (the limitation - can't use typed inputs)
      assert output_type == :post
      assert input_type == :json_string

      # The "bug" or limitation is that we can't get typed inputs
      # Removing !input? would allow both to work, but then we'd need
      # to handle the case where output types can't be used as inputs
    end
  end
end
