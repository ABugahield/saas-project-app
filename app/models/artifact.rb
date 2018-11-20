class Artifact < ApplicationRecord
  belongs_to :project
  attr_accessor :upload 
  MAX_FILESIZE = 10.megabytes
  validates_presence_of :name, :upload
  validates_uniqueness_of :name
  validate :uploaded_file_sieze
  before_save :upload_to_s3

 
  private

  def upload_to_s3
    s3 = Aws::S3::Resource.new 
    tenant_name = Tenant.find(Thread.current[:tenant_id]).name
    obj = s3.bucket(ENV['S3_BUCKET']).object("#{tenant_name}/#{upload.original_filename}")
    obj.upload_file(upload.path, acl: 'public-read')
    self.key = obj.public_url
  end 

  def uploaded_file_sieze
    if upload
      errors.add(:upload, "File size must be less then 
        #{self.class::MAX_FILESIZE}")unless upload.size <= self.class::MAX_FILESIZE
    end 
  end
end 
