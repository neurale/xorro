require_relative 'test_helper.rb'
require_relative '../lib/node.rb'
require_relative "../lib/routing_table.rb"
require_relative "../lib/kbucket.rb"
require_relative "../lib/contact.rb"
require_relative "../lib/fake_network_adapter.rb"

class KBucketTest160 < Minitest::Test
  def setup
    Defaults::ENVIRONMENT[:bit_length] = 160
    Defaults::ENVIRONMENT[:k] = 2
    @kn = FakeNetworkAdapter.new
    @node = Node.new('0', @kn)
    @bucket = KBucket.new(@node)
    @contact = @node.to_contact
    @largest = 2**Defaults::ENVIRONMENT[:bit_length]
  end

  def test_create_bucket
    assert_instance_of(KBucket, @bucket)
    assert_equal([], @bucket.contacts)
    assert_equal(true, @bucket.splittable)
  end

  def test_add_contact
    @bucket.add(@contact)

    assert_equal(1, @bucket.contacts.size)
  end

  def test_delete_contact
    @bucket.add(@contact)
    @bucket.delete(@bucket.contacts[0])

    assert_equal(0, @bucket.contacts.size)
  end

  def test_delete_contact_that_is_not_included
    @bucket.add(@contact)
    contact = Node.new('1', @kn).to_contact
    @bucket.delete(contact)

    assert_equal(1, @bucket.contacts.size)
  end

  def test_head_tail_one_contact
    @bucket.add(@contact)

    assert_equal(@bucket.contacts[0], @bucket.head)
    assert_equal(@bucket.contacts[0], @bucket.tail)
  end

  def test_head_tail_two_contacts
    @bucket.add(@contact)
    @bucket.add(id: '1', ip: '')

    assert_equal(@bucket.contacts[0], @bucket.head)
    assert_equal(@bucket.contacts[1], @bucket.tail)
  end

  def test_bucket_is_full
    @bucket.add(@contact)
    @bucket.add(id: '1', ip: '')

    assert(@bucket.full?)
  end

  def test_bucket_is_not_full
    @bucket.add(@contact)

    refute(@bucket.full?)
  end

  def test_find_contact_by_id
    @bucket.add(@contact)
    found_contact = @bucket.find_contact_by_id(@node.id)

    assert_equal(@bucket.contacts[0], found_contact)
  end

  def test_find_contact_by_id_no_match
    @bucket.add(@contact)
    found_contact = @bucket.find_contact_by_id('1')

    assert_nil(found_contact)
  end

  def test_make_unsplittable
    @bucket.make_unsplittable

    refute(@bucket.splittable)
  end

  def test_is_redistributable
    @bucket.add(Node.new('15', @kn).to_contact)
    @bucket.add(Node.new('7', @kn).to_contact)

    result = @bucket.redistributable?('0', 0)
    assert(result)
  end

  def test_is_not_redistributable
    no_shared_id = (@largest - 1).to_s
    no_shared_id2 = (@largest - 2).to_s

    @bucket.add(Node.new(no_shared_id, @kn).to_contact)
    @bucket.add(Node.new(no_shared_id2, @kn).to_contact)

    result = @bucket.redistributable?('0', 0)
    refute(result)
  end

  def test_sort_by_seen
    @bucket.add(@contact)
    @bucket.add(Node.new('7', @kn).to_contact)

    @bucket.head.update_last_seen
    @bucket.sort_by_seen

    assert_equal('7', @bucket.head.id)
  end

  def test_attempt_eviction_pingable
    @bucket.add(Node.new('15', @kn).to_contact)
    @bucket.add(Node.new('14', @kn).to_contact)

    @bucket.attempt_eviction(Contact.new(id: '13', ip: ''))

    assert_equal('15', @bucket.tail.id)
    assert_equal('14', @bucket.head.id)
  end

  def test_attempt_eviction_not_pingable
    @bucket.add(Node.new('15', @kn).to_contact)
    @bucket.add(Node.new('14', @kn).to_contact)

    @kn.nodes.delete_at(1)
    @bucket.attempt_eviction(Node.new('13', @kn).to_contact)

    assert_equal('13', @bucket.tail.id)
    assert_equal('14', @bucket.head.id)
  end
end
