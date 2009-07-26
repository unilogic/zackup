require 'ezcrypto'

class ZackupCrypt
  def self.the_key
    # Please CHNAGE the "key", and "salt" values below!! 
    # Feel free to use "rake secret" to generate some really long values. 
    #
    # NOTE: Because this is using 2-way encryption and the password and salt are stored RIGHT here
    #       this is not a super secure way of storing data. It's main purpose is to keep passwords from
    #       being stored in plaintext in the database, yet allow other parts of the software to still use the passwords. 
    #       If someone can read this file they can easily create a way to unencrypt passwords.
    #       YOU HAVE BEEN WARNED!!!
    #       Also if you change the below don't forget to edit application.rb in the rails controller folder!
    
    key = '85bb751ee853a388be42c0579822bc75e258bbfbffefbbb012af48f3c7ce70567742d6a804a87142748e68c599c1740cfdcf80cdda8fdab8c11b299469e42803'
    salt = '5990acbe43a061f06a3da020478f5d342cc3616319c86ae71d80fd3d6eea891293d19c683008fa3837fd704d4a0c68355b76f907a4552f1c92e6f2b7bd1b5734'
    @theKey ||= EzCrypto::Key.with_password(key, salt)
  end
end