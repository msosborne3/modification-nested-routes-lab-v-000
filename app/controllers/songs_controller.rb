class SongsController < ApplicationController
  def index
    if params[:artist_id]
      @artist = Artist.find_by(id: params[:artist_id])
      if @artist.nil?
        redirect_to artists_path, alert: "Artist not found"
      else
        @songs = @artist.songs
      end
    else
      @songs = Song.all
    end
  end

  def show
    if params[:artist_id]
      @artist = Artist.find_by(id: params[:artist_id])
      @song = @artist.songs.find_by(id: params[:id])
      if @song.nil?
        redirect_to artist_songs_path(@artist), alert: "Song not found"
      end
    else
      @song = Song.find(params[:id])
    end
  end

  def new
    # if user goes through /artists/1/songs/new for example, but the artist
    # doesn't exist, redirect to list of artists.
    if params[:artist_id] && !Artist.exists?(params[:artist_id])
      redirect_to artists_path, alert: "Artist not found."
    else
      # otherwise create a new song with the artist_id already set
      @song = Song.new(artist_id: params[:artist_id])
    end
  end

  def create
    @song = Song.new(song_params)

    if @song.save
      redirect_to @song
    else
      render :new
    end
  end

  def edit
    # if user goes through /artists/1/songs/3/edit for example
    if params[:artist_id]
      @artist_given = true # used in a helper to tell if the user went through the nested route

      artist = Artist.find_by(id: params[:artist_id])
      if artist.nil? # if there is no artist matching the given id, return to artists index
        redirect_to artists_path, alert: "Artist not found."
      else # otherwise find the given song by the given artist
        @song = artist.songs.find_by(id: params[:id])
        # if the song doesn't exist, return to the list of the artists songs
        redirect_to artist_songs_path(artist), alert: "Song not found." if @song.nil?
      end
    else
      # if someone just went directly to editing the song without going through artists,
      # find the requested song.
      @song = Song.find(params[:id])
    end
  end

  def update
    @song = Song.find(params[:id])

    @song.update(song_params)

    if @song.save
      redirect_to @song
    else
      render :edit
    end
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    flash[:notice] = "Song deleted."
    redirect_to songs_path
  end

  private

  def song_params
    params.require(:song).permit(:title, :artist_name, :artist_id)
  end
end

