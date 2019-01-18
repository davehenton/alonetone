include ActionDispatch::TestProcess
muppet_upload = fixture_file_upload(File.join('spec/fixtures/files/muppets.mp3'), 'audio/mpeg')

def put_user_credentials(username, password)
  puts "You can now sign in with: #{username} - #{password}"
end

# Create admin account.
admin_password = 'testing123'
admin = User.create(
  login: 'admin',
  email: '123@123.com',
  password: admin_password,
  password_confirmation: admin_password,
  admin: true
)
put_user_credentials(admin.login, admin_password)

# Create moderator account.
moderator_password = 'mod123'
moderator = User.create(
  login: 'admin',
  email: 'mod@mod.com',
  password: moderator_password,
  password_confirmation: moderator_password,
  moderator: true
)
put_user_credentials(moderator.login, moderator_password)

# Create regular musician account.
musician_password = 'music123'
musician = User.create!(
  login: 'musician',
  email: 'musician@example.com',
  password: musician_password,
  password_confirmation: musician_password,
  greenfield_enabled: true
)
put_user_credentials(musician.login, musician_password)

# Create a regular musician account with playlists and tracks.
marie_password = 'testing123'
marie = User.create!(
  login: 'marieh',
  email: 'marie.harel@example.com',
  password: marie_password,
  password_confirmation: marie_password,
  greenfield_enabled: true
)
put_user_credentials(marie.login, marie_password)

# Create a few assets for the musician.
instrument_of_accession = marie.assets.create(
  audio_file: muppet_upload,
  title: 'Commonly Blue-grey',
  description: 'The color of camembert rind was a matter of chance, most commonly blue-grey, with brown spots.',
  waveform: Greenfield::Waveform.extract(muppet_upload.path)
)
tropical_semi_evergreen = marie.assets.create(
  audio_file: muppet_upload,
  title: 'Aqueous Suspension',
  description: 'The surface of each cheese is then sprayed with an aqueous suspension of the mold Penicillium camemberti.',
  waveform: Greenfield::Waveform.extract(muppet_upload.path)
)

# Add the assets to a playlist.
playlist = marie.playlists.build(
  title: 'Before fungi were understood',
  year: Date.today.year - 1
)
playlist.description = <<~DESC
  The variety named Camembert de Normandie was granted a protected designation of origin in 1992
  after the original AOC in 1983.
DESC
playlist.save!
playlist.tracks.create!(user: marie, asset: instrument_of_accession)
playlist.tracks.create!(user: marie, asset: tropical_semi_evergreen)
playlist.update(private: false)

# Some random listens.
Asset.find_each do |asset|
  User.find_each do |user|
    if rand(4) == 1
      asset.listens.create(
        listener: user,
        track_owner: asset.user,
        user_agent: 'seeds/v1.0',
        ip: '127.0.0.1'
      )
    end
  end
end
