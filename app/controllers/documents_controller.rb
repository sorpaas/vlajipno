class DocumentsController < ApplicationController
  def index
    @documents = Document.where('title IS NOT NULL')
  end

  def edit
    @document = Document.find_by name: params[:name]
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
    @definified_content = definify @document.content
  end

  private
  def definify(content)
    if not content
      return ''
    end

    content.split(' ').map do |x|
      e = Entry.find_by word: x.gsub(/[^A-Za-z0-9']/, "")
      if e
        converter = PandocRuby.new(e.definition, from: :latex, to: :html)
        "<a href=\"#\" class=\"definified\" title='#{converter.convert.html_safe}'>#{x}</a> "
      else
        "#{x} "
      end
    end.join(' ')
  end
end
