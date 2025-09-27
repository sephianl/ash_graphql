defmodule AshGraphql.JsonStringBugTest do
  use ExUnit.Case, async: false

  describe "JSONString bug demonstration" do
    test "struct with instance_of falls back to json_string for both input and output" do
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
      # The output should ideally return the proper type if configured
      # The input should return json_string as a fallback
      IO.puts("Output type: #{inspect(output_type)}")
      IO.puts("Input type: #{inspect(input_type)}")
      
      # Currently both are json_string (bug)
      assert output_type == :json_string
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