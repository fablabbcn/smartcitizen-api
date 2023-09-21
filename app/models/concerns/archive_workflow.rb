# issue with regular concerns https://github.com/geekq/workflow/issues/152

module ArchiveWorkflow

  def self.included(base)

    base.scope :with_active_state, -> { where(workflow_state: :active) }
    base.scope :with_archived_state, -> { where(workflow_state: :archived) }

    base.workflow do
      state :active do
        event :archive, :transitions_to => :archived
      end
      state :archived do
        event :unarchive, :transitions_to => :active
      end
      after_transition do

        begin
          if archived?
            pg_search_document.destroy
          elsif active?
            update_pg_search_document
          end
        rescue
        end

        if respond_to?(:owner_id) and owner_id.present?
          User.unscoped.find(owner_id).update_all_device_ids!
        end

      end
    end
  end

end
