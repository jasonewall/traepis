class ApplicationRepository
  def save(record)
    if record.valid?
      commit(record)
    else
      @errors = record.errors
      false
    end
  end

  def errors
    @errors
  end

  def commit(record)
    committed = if record.persisted?
                  update(record)
                else
                  create_new(record)
                end

    record.commit if committed
  end

  def destroy(record)
    delete(record)
  end
end
