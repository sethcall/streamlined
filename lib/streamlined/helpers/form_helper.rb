module Streamlined::Helpers::FormHelper
  # If the validation_reflection plugin is available and working properly, check to see if the given 
  # column allows for a nil assignment.  If so, return the "Unassigned" choice.  Otherwise, return nothing.
  def unassigned_if_allowed(model_class, column, items)
    choice = "<option value='nil' #{'selected' unless items}>Unassigned</option>"
    return choice unless model_class.respond_to?('reflect_on_validations_for')
    require 'facet/module/alias_method_chain' unless Module.respond_to?('alias_method_chain')
    return choice unless Module.respond_to?('alias_method_chain')
    model_class.reflect_on_validations_for(column).collect(&:macro).include?(:validates_presence_of) ? '' : choice
  end
  
  # Return a boolean based on whether or not the the given column allows for a nil assignment.
  def column_can_be_unassigned?(model_class, column)
    return true unless model_class.respond_to?('reflect_on_validations_for')
    !model_class.reflect_on_validations_for(column).collect(&:macro).include?(:validates_presence_of)
  end
end