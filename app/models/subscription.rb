class Subscription < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  validates :user_name, presence: true, unless: -> { user.present? }
  validates :user_email, presence: true, format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/,unless: -> { user.present? }

  validates :user, uniqueness: { scope: :event_id}, if: -> { user.present?}
  validates :user_email, uniqueness: { scope: :event_id}, unless: -> { user.present?}
  validate :current_user_event
  validate :email_is_free, unless: :user_present?

  def user_name
    if user.present?
      user.name
    else
      super
    end
  end

  def user_email
    if user.present?
      user.email
    else
      super
    end
  end

  def user_present?
    user.present?
  end

  private

  def current_user_event
    if user_email == event.user.email
      errors.add(:user_email, :taken)
    end
  end

  def email_is_free
    if User.exists?(email: user_email)
    errors.add(:user_email, :taken)
    end
  end
end
