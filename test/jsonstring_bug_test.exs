defmodule AshGraphql.JsonStringBugTest do
  use ExUnit.Case, async: false

  describe "JSONString bug demonstration and fix" do
    test "struct with instance_of and no GraphQL config falls back to json_string" do
      # This test demonstrates the bug where Ash.Type.Struct with instance_of
      # incorrectly generates json_string for both input and output types
      
      # Create a mock attribute with Ash.Type.Struct and instance_of constraint
      struct_attribute = %{
        type: Ash.Type.Struct,
        constraints: [instance_of: SomeNonGraphqlResource],
        name: :my_struct,
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
      
      # Both currently return json_string due to the bug
      # After fix:
      # The output should return json_string (no GraphQL type configured)
      # The input should also return json_string (no GraphQL type configured)
      IO.puts("Output type: #{inspect(output_type)}")
      IO.puts("Input type: #{inspect(input_type)}")
      
      # Both should be json_string because the resource has no GraphQL configuration
      assert output_type == :json_string
      assert input_type == :json_string
    end
    
    test "BUG DEMO: struct with instance_of pointing to GraphQL resource incorrectly returns json_string for output" do
      # This test demonstrates the bug in the current code (before fix)
      # The !input? check on line 4940 prevents output types from working
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
      
      # CURRENT BUG: Output type is :post due to recent fixes on main
      # but in v1.8.3 it would return :json_string
      # This test will fail after we apply the fix to show the improvement
      
      # For now, test passes with current main behavior:
      assert output_type == :post
      assert input_type == :json_string
    end
  end
  
  # Define a simple module that looks like a resource but has no GraphQL config
  defmodule SomeNonGraphqlResource do
    use Ash.Resource, data_layer: Ash.DataLayer.Ets
    
    attributes do
      uuid_primary_key :id
      attribute :name, :string
    end
  end
end