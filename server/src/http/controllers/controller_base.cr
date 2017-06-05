module DMACServer
  module HttpAPI
    module ControllerBase

      private def error(ctx, message : String, code : Int32 = 422)
        ctx.response.status_code = code
        {errors: message}.to_json
      end

      private def get_param(ctx, param_string) : String?
        return ctx.params.json[param_string].to_s if ctx.params.json.has_key?(param_string)
        return ctx.params.url[param_string].to_s if ctx.params.url.has_key?(param_string)
        return ctx.params.query[param_string].to_s if ctx.params.query.has_key?(param_string)
      end

      private def get_param!(ctx, param_string) : String
        param = get_param(ctx, param_string)
        return param unless param.nil?
        raise InsufficientParameters.new("param #{param_string} does not exist")
      end

      private def changeset_errors(changeset)
        String.build do |io|
          changeset.errors.each do |error|
            io << "#{error[:field]} " unless error[:field] == "_base"
            io << "#{error[:message]}"
          end
        end
      end

    end
  end
end
