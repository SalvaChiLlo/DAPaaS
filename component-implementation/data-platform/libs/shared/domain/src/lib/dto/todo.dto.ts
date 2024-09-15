import * as S from '@effect/schema/Schema';
import { UserDto } from './user.dto';
import { BaseDto } from './base.dto';

export const TodoDto = S.Struct({
  ...BaseDto.fields,
  title: S.String.pipe(
    S.minLength(0),
    S.maxLength(20)
  ),
  description: S.String.pipe(
    S.minLength(0),
    S.maxLength(100)
  ),
  completed: S.Boolean,
})
export type TodoDto = S.Schema.Type<typeof TodoDto>

export const CreateTodoDto = TodoDto.pick('title', 'description')
export type CreateTodoDto = S.Schema.Type<typeof CreateTodoDto>

export const UpdateTodoDto = S.partial(TodoDto.pick('title', 'description', 'completed'))
export type UpdateTodoDto = S.Schema.Type<typeof UpdateTodoDto>
