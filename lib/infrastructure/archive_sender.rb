require 'sidekiq'
require 'pony'

class ArchiveSender
  include Sidekiq::Worker

  def perform(zip_file_path, recipient_email)
    puts "Starting to send archive to #{recipient_email}"

    Pony.mail(
      to: recipient_email,
      subject: "Archived Results",
      body: "Please find attached the archived results.",
      attachments: { "results.zip" => File.read(zip_file_path) },
      via: :smtp,
      via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        user_name: 'partymaker.sigma@gmail.com',
        password: 'SUPERSECURE',
        authentication: :plain,
      }
    )
    puts "Archive sent to #{recipient_email}"
  rescue StandardError => e
    puts "Failed to send archive: #{e.message}"
  end
end
