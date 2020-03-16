require_dependency "annotot/application_controller"
require 'json'

module Annotot
  class AnnotationsController < ApplicationController
    before_action :set_annotation, only: %i[update destroy]

    # GET /annotations
    def index
      @annotations = Annotation.where(canvas: annotation_search_params)
    end

    # Get /annotations/lists
    def lists
      @annotations = Annotation.where(canvas: annotation_search_params)
    end
    
    def show
      @annotation = Annotation.find_by(uuid: params[:id])
      render json: @annotation.data
    end
    
    # Get /annotations/search
    def search
        @results = Annotation.all.map{|elem|JSON.parse(elem.data)}
        if params[:q]
            @results = @results.select {|item| item['resource'].map{|elem|elem['chars']}.join(" ").include?(params[:q])}
        end
    end
    # POST /annotations
    def create
      @annotation = Annotation.new(annotation_params)

      if @annotation.save
        render json: @annotation.data
      else
        render status: :bad_request, json: {
          message: 'An annotation could not be created'
        }
      end
    end

    # PATCH/PUT /annotations/1
    def update
      if @annotation.update(annotation_params)
        render status: :ok, json: @annotation.data
      else
        render status: :bad_request, json: {
          message: 'Annotation could not be updated.',
          status: :bad_request
        }
      end
    end

    # DELETE /annotations/1
    def destroy
      @annotation.destroy
      render status: :ok, json: {
        message: 'Annotation was successfully destroyed.'
      }
    end

    private

    def set_annotation
      @annotation = Annotot::Annotation.retrieve_by_id_or_uuid(
        CGI.unescape(params[:id])
      )
      raise ActiveRecord::RecordNotFound unless @annotation.present?
    end

    def annotation_params
      params.require(:annotation).permit(:uuid, :data, :canvas, :creator)
    end

    def annotation_search_params
      CGI.unescape(params.require(:uri))
    end
  end
end
