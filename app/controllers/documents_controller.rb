class DocumentsController < ApplicationController
  def index
    @title = "Home"
    @documents = Document.where('title IS NOT NULL').select { |x| x.title.present? }
  end

  def edit
    @document = Document.find_by name: params[:name]
    @title = @document.title.present? ? @document.title : "Edit"
  end

  def create
    name = SecureRandom.uuid

    @document = Document.create name: name
    redirect_to "/#{name}/edit"
  end

  def update
    @document_attrs = params.require(:document).permit(:id, :name, :title, :content)
    @document = Document.find @document_attrs[:id]
    if @document == nil
      flash[:error] = "Document not exist. "
      redirect_to :back
    elsif Document.find_by name: @document_attrs[:name].downcase != nil
      flash[:error] = "Document url already existed. "
      redirect_to :back
    elsif /[^A-Za-z0-9\-]/ =~ @document_attrs[:name]
      flash[:error] = "Document url can only contain [A-Za-z0-9\\-]. "
      redirect_to :back
    elsif @document_attrs[:name] == nil or @document_attrs[:name].strip == ""
      flash[:error] = "Document url cannot be blank. "
      redirect_to :back
    else
      @document.name = @document_attrs[:name].downcase
      @document.title = @document_attrs[:title]
      @document.content = @document_attrs[:content]
      @document.save
      redirect_to "/#{@document.name}"
    end
  end

  def view
    @document = Document.find_by name: params[:name].downcase
    @definified_title = definify @document.title

    @markdown_content = markdown_renderer.render(@document.content)
    @nokogiri_content = Nokogiri::HTML::DocumentFragment.parse(@markdown_content)
    @replacing_nodes = []
    @nokogiri_content.traverse do |x|
      if x.text?
        @replacing_nodes << x
      end
    end
    @replacing_nodes.each do |x|
      x.content.split(' ').map do |word|
        entry = Dictionary.query word.gsub(/[^A-Za-z0-9']/, "")
        if entry
          node = Nokogiri::XML::Node.new('a', @nokogiri_content)
          node['href'] = '#'
          node['class'] = 'definified'
          node['title'] = entry
          node.content = word
          x.parent << node
          x.parent << " "
        else
          x.parent << " "
        end
      end

      x.remove
    end
    @definified_content = @nokogiri_content.to_s
    @title = @document.title.present? ? @document.title : "(No Title)"
  end

  private
  def markdown_renderer
    if not @markdown_renderer
      @markdown_renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    end
    @markdown_renderer
  end

  def definify(content)
    if not content
      return ''
    end

    content.split(' ').map do |x|
      entry = Dictionary.query x.gsub(/[^A-Za-z0-9']/, "")
      if entry
        "<a href=\"#\" class=\"definified\" title='#{entry}'>#{x}</a> "
      else
        "#{x} "
      end
    end.join(' ')
  end
end
