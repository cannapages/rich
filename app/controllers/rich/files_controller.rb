require 'mime/types'

module Rich
  class FilesController < ApplicationController
    
    def index
      # filter for allowed styles, default to all available
      
      #logger.debug("#{Rich.allowed_styles.inspect}")
      
      if (Rich.allowed_styles == :all)
        @styles = Rich.image_styles.keys
        @styles.push(:original)
      else 
        @styles = Rich.allowed_styles
      end
      
      @default_style = Rich.default_style
      
      # list all files
      @images = RichImage.all(:order => "created_at DESC")
      
      # stub for new file
      @rich_image = RichImage.new
    end
    
    def show
      # show is used to retrieve single images through XHR requests after an image has been uploaded
      
      if(params[:id])
        # list all files
        @file = RichImage.find(params[:id])
        render :layout => false
      else 
        render :text => "Image not found"
      end
      
    end
    
    def create
      #render :json => { :success => false, :error => "File is too large..." }
      #render :json => { :success => true, :rich_id => 1 }

      @file = RichImage.new
      
      

      
      # use the file from Rack Raw Upload
      if(params[:file])
        # Rack Raw Upload always passes octet/stream, so we need to figure it out ourselves.
        params[:file].content_type = MIME::Types.type_for(params[:file].original_filename)
        
        @file.image = params[:file]
      end
      
      logger.debug("DIT IS HEM >> #{params[:file].inspect}")
      
      if @file.save
        render :json => { :success => true, :rich_id => @file.id }
      else
        render :json => { :success => false, 
                          :error => "Could not upload your file:\n- "+@file.errors.to_a[-1].to_s,
                          :params => params.inspect }
                          
                          # :error => "Could not upload your file:\n"+@file.errors.map {
                          #                             |k,v|
                          #                             "- "+v+"\n"
                          #                           }.to_s,
                          #                           
                          
      end
      
      # if @article.save
      #       if is_qq
      #         render :json => { "success" => true }
      #       else
      #         # as before, likely:
      #         # redirect_to(articles_path, :notice => "Article was successfully created.")
      #       end
      #     else
      #       if is_qq
      #         render :json => { "error" => @article.errors }
      #       else
      #         # as before, likely:
      #         # render :action => :new
      #       end
      #     end
      
      # @rich_image = RichImage.new(params[:rich_image])
      #       if @rich_image.save
      #         flash[:notice] = "Successfully created image."
      #         redirect_to :action => 'index'
      #       else
      #         redirect_to :action => 'index'
      #       end
    end
    
    def destroy  
      if(params[:id])
        image = RichImage.delete(params[:id])
        @fileid = params[:id]
      end
    end
    
  end
end
