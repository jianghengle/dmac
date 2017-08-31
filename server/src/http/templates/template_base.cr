macro my_render(filename)
  ECR.def_to_s "src/http/templates/#{{{filename}}}.ecr"
end
    

