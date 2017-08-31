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

      private def get_header(ctx, header_string) : String?
        return ctx.request.headers[header_string].to_s if ctx.request.headers.has_key?(header_string)
      end

      private def get_header!(ctx, header_string) : String
        header = get_header(ctx, header_string)
        return header unless header.nil?
        raise InsufficientParameters.new("header #{header_string} does not exist")
      end

      private def get_body(ctx, body_string) : String?
        return ctx.params.body[body_string].to_s if ctx.params.body.has_key?(body_string)
      end

      private def get_body!(ctx, body_string) : String
        body = get_body(ctx, body_string)
        return body unless body.nil?
        raise InsufficientParameters.new("body #{body_string} does not exist")
      end

      private def verify_token(ctx) 
        token = get_header!(ctx, "Authorization")
        return User.get_user(token).email.to_s
      end

      private def json_array(arr)
        result = String.build do |str|
          first = true
          str << "["
          arr.each do |e|
            if first
              str << e
              first = false
            else
              str << ","
              str << e
            end
          end
          str << "]"
        end
        result
      end

    end
  end
end
