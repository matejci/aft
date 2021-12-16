module Mongoid
  module Association
    module Referenced
      module AutoSave
        def self.define_autosave!(association)
          association.inverse_class.tap do |klass|
            save_method = :"autosave_documents_for_#{association.name}"
            klass.send(:define_method, save_method) do
              if before_callback_halted?
                self.before_callback_halted = false
              else
                __autosaving__ do
                  if relation = ivar(association.name)
                    # Array(relation).each do |doc|
                    # NOTE: only save association with changes
                    Array(relation).find_all{ |doc| changed_for_autosave?(doc) }.each do |doc|
                      doc.with(persistence_context) do |d|
                        d.save
                      end
                    end
                  end
                end
              end
            end
            klass.after_save save_method, unless: :autosaved?
          end
        end
      end
    end

    module Nested
      class Many
        def update_document(doc, attrs)
          attrs.delete_id

          # if association.embedded?
          #   doc.assign_attributes(attrs)
          # else
          #   doc.update_attributes(attrs)
          # end

          # NOTE: so it does not save before parent saves
          doc.assign_attributes(attrs)
        end
      end
    end
  end

  class Criteria
    module Queryable
      module Aggregable
        def lookup(operation = nil)
          aggregation(operation) do |pipeline|
            pipeline.lookup(operation)
          end
        end

        def match(operation = nil)
          aggregation(operation) do |pipeline|
            pipeline.match(operation)
          end
        end
      end

      class Pipeline < Array
        def lookup(entry)
          push('$lookup' => evolve(entry))
        end

        def match(entry)
          push('$match' => evolve(entry))
        end
      end
    end

    def aggregate
      collection.aggregate pipeline
    end

    def post_order(key)
      key ||= :newest # default to show most recent
      reorder(Post.sort_option(key))
    end
  end
end
