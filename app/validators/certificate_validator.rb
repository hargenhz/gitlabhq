# UrlValidator
#
# Custom validator for private keys.
#
#   class Project < ActiveRecord::Base
#     validates :certificate_key, certificate: true
#   end
#
class CertificateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_certificate_pem?(value)
      record.errors.add(attribute, "must be a valid PEM certificate")
    end
  end

  private

  def valid_certificate_pem?(value)
    return unless value
    OpenSSL::X509::Certificate.new(value)
  rescue OpenSSL::X509::CertificateError
    nil
  end
end
