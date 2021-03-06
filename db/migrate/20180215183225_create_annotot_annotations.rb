class CreateAnnototAnnotations < ActiveRecord::Migration[5.1]
  def change
    create_table :annotot_annotations do |t|
      t.string :uuid, index: true
      t.string :canvas, index: true
      t.binary :data
      t.string :creator, array: true, default: []
      t.timestamps
    end
    add_index :annotot_annotations, :creator
  end
end
