module AsciidoctorBibliography
  class Index
    attr_reader :parent, :target, :attrs, :uuid

    def initialize(parent, target, attrs, uuid)
      @parent = parent
      @target = target
      @attrs = attrs
      @uuid = uuid
    end

    def placeholder
      "{#{uuid}}"
    end

    # attr_reader :ref, :pages

    # def initialize ref, pages
    #   @ref = ref
    #   @pages = pages
    #   # clean up pages
    #   @pages = '' unless @pages
    #   @pages.gsub!("--","-")
    # end

    # def to_s
    #   "#{@ref}:#{@pages}"
    # end
  end
end

