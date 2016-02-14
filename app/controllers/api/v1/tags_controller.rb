class Api::V1::TagsController < ApplicationController

    acts_as_token_authentication_handler_for User
    
    def index
        @tags = Tag.all
    end
end
