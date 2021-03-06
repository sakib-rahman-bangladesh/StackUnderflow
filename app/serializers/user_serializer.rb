class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :reputation, :small_avatar_url, :medium_avatar_url, :tiny_avatar_url, :website, :location, :age, :full_name

  def tiny_avatar_url
    object.avatar.tiny.url
  end
  
  def small_avatar_url
    object.avatar.small.url
  end

  def medium_avatar_url
    object.avatar.medium.url
  end

  def reputation
    object.reputation_sum
  end
end
