package org.upct.tr.tests

import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.InjectWith
import org.junit.runner.RunWith
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.junit.Test
import javax.inject.Inject

@RunWith(XtextRunner)
@InjectWith(TRInjectorProvider)
class TRGeneratorTest {

	@Inject extension CompilationTestHelper

	val SOURCE_CODE = '''
		enums
		dir ::= left | right
		thing ::= bottle | drop
		end
		
		percepts
		holding: ()
		see: (thing)
		touching: ()
		over_drop: ()
		gripper_open: ()
		end
		
		beliefs
		
		end
		
		durative
		move: (double)
		turn: (dir)
		end
		
		discrete
		open_gripper: ()
		close_gripper: ()
		end
		
		vars
		int _collected := 0
		int _other_collected := 0
		int total := 10
		end
		
		goals
		collect_bottles:(string)
		collect_bottles(OtherAg){ 
		 _collected + _other_collected >= total -> ()
		 holding() and over_drop() -> drop_and_leave(OtherAg)
		 holding() -> get_to_drop()
		 true -> get_bottle()
		}
		
		drop_and_leave:(string) 
		drop_and_leave(OtherAg){
		 gripper_open() -> leave_drop()
		 // Fix issue #2 - removed undefined procedure call
		 true -> open_gripper() ++ _collected := _collected + 1
		}
		
		leave_drop:()
		leave_drop(){
		 not see(thing.drop) and not see(thing.bottle) -> move(1.0)
		 see(thing.drop) -> turn(dir.left, 0.8)
		 see(thing.bottle) -> turn(dir.right, 0.8)
		}
		
		get_to_drop:()
		get_to_drop(){
		 over_drop() -> ()
		 see(thing.drop) -> move(1.5)
		 true -> turn(dir.left,1.0) for 2; move(1.0) for 2
		}
		
		get_bottle:()
		get_bottle(){
		 holding() -> ()
		 touching() and gripper_open() -> close_gripper()
		 touching() -> open_gripper()
		 see(thing.bottle) -> move(1.5)
		 true -> turn(dir.left,1.0) for 2.8; move(1.0) for 2
		}
		end
		
		messages
		handle(_,"count", val) -> _other_collected := val
		end";
	'''
	
	@Test
	def void testGoalGeneration() {
		SOURCE_CODE.assertCompilesTo('''
		-module(tr).
		-export([
		collect_bottles/0,
		drop_and_leave/0,
		leave_drop/0,
		get_to_drop/0,
		get_bottle/0
		]).
		
		collect_bottles() ->
			case {
				bs:get_belief(collected)+bs:get_belief(other_collected)>=bs:get_belief(total)
			}
		drop_and_leave() ->
			case {
			}
		leave_drop() ->
			case {
			}
		get_to_drop() ->
			case {
			}
		get_bottle() ->
			case {
			}
		''')
	}
}
