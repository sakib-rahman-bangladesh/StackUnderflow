class Answer < ActiveRecord::Base
  include Votable

  default_scope { order("best DESC, votes_sum DESC, created_at ASC") }

  belongs_to :question, counter_cache: true
  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, reject_if: proc { |attrs| attrs['file'].blank? && attrs['file_cache'].blank? }

  validates :body, presence: true, length: { in: 10..5000 }

  after_save :update_question_activity
  after_create :send_notification

  paginates_per 10

  def mark_best!
    unless question.has_best_answer?
      update(best: true)
      Reputation.add_to(user, :answer_mark_best)
    end
  end

  def notify_subscribers
    question.favorites.find_each do |fuser|
      AnswerMailer.new_for_subscribers(fuser, question).deliver
    end if question
  end

  private
    def update_question_activity
      question.save
    end

    def send_notification
      self.delay.notify_subscribers
    end
end
