class AnalyticsController < ApplicationController
  def crash
    @crash = Crash.create(crash_params)
    respond_to do |format|
      format.json { render json: @crash }
    end
  end

  def version
    @version = CheckVersion.new(version_params)

    @version.app_version = HTTParty.get("https://api.github.com/repos/ferdi2005/monumenti/releases/latest").to_h["tag_name"]
    
    sem_app_version = Semantic::Version.new @version.app_version.delete_prefix("v").split(".")[0..2].join(".")

    sem_old_version = Semantic::Version.new @version.old_version.split(".")[0..2].join(".")
    
    if sem_app_version > sem_old_version
      @version.updated = false
    else
      @version.updated = true
    end

    @version.save

    respond_to do |format|
      format.json { render json: @version }
    end
  end
end
private
def version_params
  params.permit(:old_version, :uuid, :device_name, :os, :os_version, :model)
end

def crash_params
  params.permit(:data, :uuid, :device_name, :device_name, :os, :os_version, :model)
end