require "rack/utils"

class NotesApp < Sinatra::Base
    get '/' do
      @notes = Note.all
      erb :index
    end
  
    post "/note/create" do
      Note.create(title: Rack::Utils.escape_html(params[:title]),
                  body: Rack::Utils.escape_html(params[:body]))
      redirect '/'
    end

    post "/note/delete" do
        Note.delete(params[:id])
        redirect '/'
    end
  end