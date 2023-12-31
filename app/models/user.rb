class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_one_attached :profile_image
  
  has_many :group_users

  # フォローフォロワー機能
    # 自分がフォローされる側の関係性
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  
    # 被フォロー関係を通じて参照→自分をフォローしている人
  has_many :followers, through: :passive_relationships, source: :follower
  
    # 自分がフォローする側の関係性
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  
    # フォローする関係を通じて参照→自分がフォローしている人
  has_many :followings, through: :active_relationships, source: :followed
  



  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }


  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  # フォローフォロワー機能
   # current_userが別userをフォローするためにactive_relationshipsテーブルに新しいレコードを作成
  def follow(user)
    active_relationships.create(followed_id: user.id)
  end
  
   # followe_idカラムがuser.idと一致するレコードをfind_byで見つけてdestroy
  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end
  
   # 現在のユーザーが指定したユーザーをフォロー: true, フォローしていない: false
  def following?(other_user)
    followings.include?(other_user)
  end

# 検索方法分岐
  def self.looks(search, word)
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?","#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?","%#{word}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?","%#{word}%")
    else
      @user = User.all
    end
  end


end
