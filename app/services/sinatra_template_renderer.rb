module Services
  class SinatraTemplateRenderer
    def initialize(app:)
      @app = app
    end

    def render(template, locals:)
      @app.erb(template, layout: false, locals:)
    end
  end
end
